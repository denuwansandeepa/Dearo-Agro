import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import '../../../api/soil_test_report_api.dart';
import '../../../models/soil_test_report.dart';

class SoilTestReportFormScreen extends StatefulWidget {
  final SoilTestReportApi api;
  final SoilTestReport? initialReport;
  const SoilTestReportFormScreen(
      {super.key, required this.api, this.initialReport});

  @override
  State<SoilTestReportFormScreen> createState() =>
      _SoilTestReportFormScreenState();
}

class _SoilTestReportFormScreenState extends State<SoilTestReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  final TextEditingController _micronutrientsController =
      TextEditingController();
  String? _soilTexture;
  final _storage = const FlutterSecureStorage();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialReport != null) {
      _phController.text = widget.initialReport!.ph;
      _nitrogenController.text = widget.initialReport!.nitrogen;
      _phosphorusController.text = widget.initialReport!.phosphorus;
      _potassiumController.text = widget.initialReport!.potassium;
      _micronutrientsController.text = widget.initialReport!.micronutrients;
      _soilTexture = widget.initialReport!.soilTexture;
    }
  }

  @override
  void dispose() {
    _phController.dispose();
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _micronutrientsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final farmerId = await _storage.read(key: "userId");
    if (farmerId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar( SnackBar(content: Text("user_not_logged_in".tr())));
      setState(() => _isSubmitting = false);
      return;
    }
    final report = SoilTestReport(
      id: widget.initialReport?.id,
      ph: _phController.text,
      nitrogen: _nitrogenController.text,
      phosphorus: _phosphorusController.text,
      potassium: _potassiumController.text,
      micronutrients: _micronutrientsController.text,
      soilTexture: _soilTexture ?? '',
      farmerId: farmerId,
    );
    bool success;
    if (widget.initialReport != null) {
      success = await widget.api.updateReport(report);
    } else {
      success = await widget.api.submitReport(report);
    }
    setState(() => _isSubmitting = false);
    if (success) {
      if (mounted) Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(
          content: Text('failed_submit_report'.tr()),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet =
        mediaQuery.size.width >= 600 && mediaQuery.size.width < 1024;
    final isDesktop = mediaQuery.size.width >= 1024;
    final headerFontSize = isDesktop
        ? 32.0
        : isTablet
            ? 26.0
            : 20.0;
    final arcHeight = isDesktop
        ? 260.0
        : isTablet
            ? 210.0
            : 190.0;
    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: ArcClipper(),
            child: Container(
              height: arcHeight,
              color: const Color.fromRGBO(87, 164, 91, 0.8),
            ),
          ),
          Positioned(
            top: isDesktop
                ? 60
                : isTablet
                    ? 50
                    : 36,
            left: isDesktop
                ? 60
                : isTablet
                    ? 40
                    : 24,
            child: Text(
              widget.initialReport == null
                  ? 'submit_soil_test_report'.tr()
                  : 'edit_soil_test_report'.tr(),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: headerFontSize,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: isDesktop
                ? 60
                : isTablet
                    ? 50
                    : 36,
            right: isDesktop
                ? 60
                : isTablet
                    ? 40
                    : 24,
            child: Image.asset(
              "assets/icons/support.png",
              width: isDesktop
                  ? 40
                  : isTablet
                      ? 34
                      : 28,
              height: isDesktop
                  ? 40
                  : isTablet
                      ? 34
                      : 28,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: isDesktop
                    ? 120
                    : isTablet
                        ? 40
                        : 24,
                right: isDesktop
                    ? 120
                    : isTablet
                        ? 40
                        : 24,
                top: arcHeight - 40,
                bottom: 24,
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop
                        ? 48
                        : isTablet
                            ? 32
                            : 18,
                    vertical: isDesktop
                        ? 40
                        : isTablet
                            ? 28
                            : 18,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildTextField(_phController, 'soil_ph'.tr(), 'e.g. 6.5',
                            Icons.science),
                        const SizedBox(height: 16),
                        buildTextField(_nitrogenController, 'nitrogen'.tr(),
                            'e.g. 20 mg/kg', Icons.eco),
                        const SizedBox(height: 16),
                        buildTextField(_phosphorusController, 'phosphorus'.tr(),
                            'e.g. 15 mg/kg', Icons.local_florist),
                        const SizedBox(height: 16),
                        buildTextField(_potassiumController, 'potassium'.tr(),
                            'e.g. 30 mg/kg', Icons.grass),
                        const SizedBox(height: 16),
                        buildTextField(
                            _micronutrientsController,
                            'micronutrients'.tr(),
                            'e.g. Zinc, Iron, Boron',
                            Icons.bubble_chart),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _soilTexture,
                          decoration: InputDecoration(
                            labelText: 'soil_texture'.tr(),
                            prefixIcon: const Icon(Icons.terrain,
                                color: Color(0xFF57A45B)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items:  [
                            DropdownMenuItem(
                                value: 'Sandy', child: Text('sandy'.tr())),
                            DropdownMenuItem(
                                value: 'Clay', child: Text('clay'.tr())),
                            DropdownMenuItem(
                                value: 'Loam', child: Text('loam'.tr())),
                          ],
                          onChanged: (value) =>
                              setState(() => _soilTexture = value),
                          validator: (value) => value == null || value.isEmpty
                              ? 'soil_texture'.tr()
                              : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF57A45B),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _isSubmitting ? null : _submitForm,
                            child: _isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    widget.initialReport == null
                                        ? 'submit_report'.tr()
                                        : 'update_report'.tr(),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      String hint, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.black),
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF57A45B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Color.fromRGBO(87, 164, 91, 0.8), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'please_enter. $label'.tr() : null,
    );
  }
}
