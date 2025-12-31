import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import '../../../api/soil_test_report_api.dart';
import '../../../models/soil_test_report.dart';
import 'soil_test_report_form.dart';

class SoilTestScreen extends StatefulWidget {
  const SoilTestScreen({super.key});

  @override
  State<SoilTestScreen> createState() => _SoilTestScreenState();
}

class _SoilTestScreenState extends State<SoilTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  final TextEditingController _micronutrientsController =
      TextEditingController();
  String? _soilTexture;
  final SoilTestReportApi _api =
      SoilTestReportApi('https://dearoagro-backend.onrender.com/api');
  final _storage = const FlutterSecureStorage();
  List<SoilTestReport> _reports = [];
  bool _isLoadingReports = false;

  @override
  void dispose() {
    _phController.dispose();
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _micronutrientsController.dispose();
    super.dispose();
  }

  Future<void> _fetchReports(String farmerId) async {
    setState(() => _isLoadingReports = true);
    try {
      final reports = await _api.getReportsByFarmer(farmerId);
      setState(() => _reports = reports);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch reports: $e')),
      );
    } finally {
      setState(() => _isLoadingReports = false);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final farmerId = await _storage.read(key: "userId");
      if (farmerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }
      final report = SoilTestReport(
        ph: _phController.text,
        nitrogen: _nitrogenController.text,
        phosphorus: _phosphorusController.text,
        potassium: _potassiumController.text,
        micronutrients: _micronutrientsController.text,
        soilTexture: _soilTexture ?? '',
        farmerId: farmerId,
      );
      final success = await _api.submitReport(report);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Soil Test Report Submitted!'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
        setState(() => _soilTexture = null);
        await _fetchReports(farmerId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit report.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFarmerReports();
  }

  Future<void> _loadFarmerReports() async {
    final farmerId = await _storage.read(key: "userId");
    if (farmerId != null) {
      await _fetchReports(farmerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet =
        mediaQuery.size.width >= 600 && mediaQuery.size.width < 1024;
    final isDesktop = mediaQuery.size.width >= 1024;
    final horizontalPadding = isDesktop
        ? mediaQuery.size.width * 0.2
        : isTablet
            ? mediaQuery.size.width * 0.08
            : 0.0;
    final cardPadding = isDesktop
        ? const EdgeInsets.symmetric(horizontal: 40, vertical: 24)
        : isTablet
            ? const EdgeInsets.symmetric(horizontal: 24, vertical: 18)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    final cardFontSize = isDesktop
        ? 20.0
        : isTablet
            ? 18.0
            : 16.0;
    final cardIconSize = isDesktop
        ? 30.0
        : isTablet
            ? 26.0
            : 22.0;
    final cardTitleFontSize = isDesktop
        ? 22.0
        : isTablet
            ? 19.0
            : 17.0;
    final cardTitleIconSize = isDesktop
        ? 34.0
        : isTablet
            ? 30.0
            : 28.0;
    final headerFontSize = isDesktop
        ? 32.0
        : isTablet
            ? 26.0
            : 20.0;
    final headerTop = isDesktop
        ? 70.0
        : isTablet
            ? 60.0
            : 50.0;
    final headerLeft = isDesktop
        ? 80.0
        : isTablet
            ? 50.0
            : 30.0;
    final headerRight = isDesktop
        ? 60.0
        : isTablet
            ? 40.0
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
            top: headerTop,
            left: headerLeft,
            child: Text(
              "My Soil Test Report",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: headerFontSize,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: headerTop,
            right: headerRight,
            child: Image.asset(
              "assets/icons/support.png",
              width: cardTitleIconSize,
              height: cardTitleIconSize,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 15 + horizontalPadding),
              child: Column(
                children: [
                  _isLoadingReports
                      ? const CircularProgressIndicator()
                      : _reports.isEmpty
                          ? Text('No soil test reports found.',
                              style:
                                  GoogleFonts.poppins(fontSize: cardFontSize))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                ..._reports.map(
                                  (r) => Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.07),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                          border: Border.all(
                                              color: const Color(0xFF57A45B)
                                                  .withOpacity(0.15),
                                              width: 1.5),
                                        ),
                                        child: Padding(
                                          padding: cardPadding,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.science,
                                                          color: const Color(
                                                              0xFF57A45B),
                                                          size:
                                                              cardTitleIconSize),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        'Soil Test',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              cardTitleFontSize,
                                                          color: const Color(
                                                              0xFF57A45B),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.edit,
                                                            color: const Color(
                                                                0xFF57A45B),
                                                            size: cardIconSize),
                                                        tooltip: 'Edit',
                                                        onPressed: () async {
                                                          final result =
                                                              await Navigator
                                                                  .push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SoilTestReportFormScreen(
                                                                api: _api,
                                                                initialReport:
                                                                    r,
                                                              ),
                                                            ),
                                                          );
                                                          if (result == true) {
                                                            final farmerId =
                                                                await _storage.read(
                                                                    key:
                                                                        "userId");
                                                            if (farmerId !=
                                                                null) {
                                                              await _fetchReports(
                                                                  farmerId);
                                                            }
                                                          }
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.delete,
                                                            color: Colors.red,
                                                            size: cardIconSize),
                                                        tooltip: 'Delete',
                                                        onPressed: () async {
                                                          final confirm =
                                                              await showDialog<
                                                                  bool>(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                              title: const Text(
                                                                  'Delete Report'),
                                                              content: const Text(
                                                                  'Are you sure you want to delete this report?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context,
                                                                          false),
                                                                  child: const Text(
                                                                      'Cancel'),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context,
                                                                          true),
                                                                  child: const Text(
                                                                      'Delete',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.red)),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                          if (confirm == true) {
                                                            final success =
                                                                await _api
                                                                    .deleteReport(
                                                                        r.id!);
                                                            if (success) {
                                                              final farmerId =
                                                                  await _storage
                                                                      .read(
                                                                          key:
                                                                              "userId");
                                                              if (farmerId !=
                                                                  null) {
                                                                await _fetchReports(
                                                                    farmerId);
                                                              }
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        'Report deleted')),
                                                              );
                                                            } else {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        'Failed to delete report'),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red),
                                                              );
                                                            }
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Table(
                                                columnWidths: const {
                                                  0: IntrinsicColumnWidth(),
                                                  1: FlexColumnWidth(),
                                                },
                                                children: [
                                                  TableRow(children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  isDesktop
                                                                      ? 18
                                                                      : isTablet
                                                                          ? 14
                                                                          : 10),
                                                      child: Row(children: [
                                                        Icon(Icons.opacity,
                                                            color: Colors.blue,
                                                            size: cardIconSize),
                                                        const SizedBox(
                                                            width: 10),
                                                        Text('pH',
                                                            style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize:
                                                                    cardFontSize)),
                                                      ]),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  isDesktop
                                                                      ? 18
                                                                      : isTablet
                                                                          ? 14
                                                                          : 10),
                                                      child: Text(r.ph,
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize:
                                                                      cardFontSize)),
                                                    ),
                                                  ]),
                                                  TableRow(children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  isDesktop
                                                                      ? 18
                                                                      : isTablet
                                                                          ? 14
                                                                          : 10),
                                                      child: Row(children: [
                                                        Icon(Icons.eco,
                                                            color: Colors.green,
                                                            size: cardIconSize),
                                                        const SizedBox(
                                                            width: 10),
                                                        Text('Nitrogen',
                                                            style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize:
                                                                    cardFontSize)),
                                                      ]),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  isDesktop
                                                                      ? 18
                                                                      : isTablet
                                                                          ? 14
                                                                          : 10),
                                                      child: Text(r.nitrogen,
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize:
                                                                      cardFontSize)),
                                                    ),
                                                  ]),
                                                  TableRow(children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  isDesktop
                                                                      ? 18
                                                                      : isTablet
                                                                          ? 14
                                                                          : 10),
                                                      child: Row(children: [
                                                        Icon(
                                                            Icons.local_florist,
                                                            color:
                                                                Colors.orange,
                                                            size: cardIconSize),
                                                        const SizedBox(
                                                            width: 10),
                                                        Text('Phosphorus',
                                                            style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize:
                                                                    cardFontSize)),
                                                      ]),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  isDesktop
                                                                      ? 18
                                                                      : isTablet
                                                                          ? 14
                                                                          : 10),
                                                      child: Text(r.phosphorus,
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize:
                                                                      cardFontSize)),
                                                    ),
                                                  ]),
                                                  TableRow(children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  isDesktop
                                                                      ? 18
                                                                      : isTablet
                                                                          ? 14
                                                                          : 10),
                                                      child: Row(children: [
                                                        Icon(Icons.grass,
                                                            color: Colors.brown,
                                                            size: cardIconSize),
                                                        const SizedBox(
                                                            width: 10),
                                                        Text('Potassium',
                                                            style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize:
                                                                    cardFontSize)),
                                                      ]),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  isDesktop
                                                                      ? 18
                                                                      : isTablet
                                                                          ? 14
                                                                          : 10),
                                                      child: Text(r.potassium,
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize:
                                                                      cardFontSize)),
                                                    ),
                                                  ]),
                                                  TableRow(children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  isDesktop
                                                                      ? 18
                                                                      : isTablet
                                                                          ? 14
                                                                          : 10),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .bubble_chart,
                                                              color:
                                                                  Colors.teal,
                                                              size:
                                                                  cardIconSize),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child: Text(
                                                              'Micronutrients',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize:
                                                                      cardFontSize),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  isDesktop
                                                                      ? 18
                                                                      : isTablet
                                                                          ? 14
                                                                          : 10),
                                                      child: Text(
                                                          r.micronutrients,
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize:
                                                                      cardFontSize)),
                                                    ),
                                                  ]),
                                                  TableRow(children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  isDesktop
                                                                      ? 18
                                                                      : isTablet
                                                                          ? 14
                                                                          : 10),
                                                      child: Row(children: [
                                                        Icon(Icons.terrain,
                                                            color: Colors
                                                                .deepPurple,
                                                            size: cardIconSize),
                                                        const SizedBox(
                                                            width: 10),
                                                        Text('Texture',
                                                            style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize:
                                                                    cardFontSize)),
                                                      ]),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  isDesktop
                                                                      ? 18
                                                                      : isTablet
                                                                          ? 14
                                                                          : 10),
                                                      child: Text(r.soilTexture,
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize:
                                                                      cardFontSize)),
                                                    ),
                                                  ]),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF57A45B),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SoilTestReportFormScreen(api: _api),
            ),
          );
          if (result == true) {
            final farmerId = await _storage.read(key: "userId");
            if (farmerId != null) {
              await _fetchReports(farmerId);
            }
          }
        },
        tooltip: 'Add Soil Test Report',
        child: const Icon(Icons.add, color: Colors.white),
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
          value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }
}
