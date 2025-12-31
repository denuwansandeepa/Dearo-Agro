import 'package:farmeragriapp/api/crop_update_api.dart';
import 'package:farmeragriapp/models/crop_update_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_fonts/google_fonts.dart';

class NewUpdateForm extends StatefulWidget {
  final dynamic existingData;

  const NewUpdateForm({super.key, this.existingData});

  @override
  State<NewUpdateForm> createState() => _NewUpdateFormState();
}

class _NewUpdateFormState extends State<NewUpdateForm> {
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final int _maxChars = 50;
  int _charCount = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final TextEditingController _fertilizerTypeController =
      TextEditingController();
  final TextEditingController _fertilizerAmountController =
      TextEditingController();
  String? _selectedFertilizerUnit;

  final List<String> _fertilizerUnits = ['Kg', 'g', 'l', 'ml'];

  // Keep crop update options in Sinhala as requested
  final Map<String, String> _cropUpdateOptions = {
    'බිම සකස් කිරීම': 'බිම සකස් කිරීම',
    'බීජ තේරීම සහ බීජ වගාව': 'බීජ තේරීම සහ බීජ වගාව',
    'රෝපණය': 'රෝපණය',
    'පොහොර යෙදීම': 'පොහොර යෙදීම',
    'ජල සපයීම': 'ජල සපයීම',
    'වාලි කිරීම සහ පාලනය': 'වාලි කිරීම සහ පාලනය',
    'වර්ධනය නිරීක්ෂණය': 'වර්ධනය නිරීක්ෂණය',
    'අස්වනු ඇස්තමේන්තුව': 'අස්වනු ඇස්තමේන්තුව',
    'අස්වනු කැපීම': 'අස්වනු කැපීම',
    'ගබඩාව': 'ගබඩාව',
    'බෙදාහැරීම': 'බෙදාහැරීම'
  };

  String? _selectedDescription;

  final Map<String, String> _fertilizerTypeOptions = {
    'කාබනික': 'කාබනික',
    'රසායනික': 'රසායනික',
    'මිශ්‍රිත': 'මිශ්‍රිත'
  };

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_updateCharCount);
    _initializeFormData();
  }

  void _updateCharCount() {
    setState(() {
      _charCount = _descriptionController.text.length;
    });
  }

  void _initializeFormData() {
    if (widget.existingData != null) {
      _selectedDescription = widget.existingData['description'];
      _descriptionController.text = _selectedDescription ?? '';

      _dateController.text = widget.existingData['addDate'] ?? '';
      _parseExistingDate();

      _fertilizerTypeController.text =
          widget.existingData['fertilizerType'] ?? '';
      _fertilizerAmountController.text =
          widget.existingData['fertilizerAmount']?.toString() ?? '';
      _selectedFertilizerUnit =
          widget.existingData['fertilizerUnit']?.toString();
    }
  }

  void _parseExistingDate() {
    if (widget.existingData['addDate'] != null) {
      try {
        final parts = widget.existingData['addDate'].split('-');
        if (parts.length == 3) {
          _selectedDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      } catch (e) {
        debugPrint("Error parsing date: $e");
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateCharCount);
    _descriptionController.dispose();
    _dateController.dispose();
    _fertilizerTypeController.dispose();
    _fertilizerAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = _formatDate(pickedDate);
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final Map<String, dynamic> updateData = {
        'id': widget.existingData != null ? widget.existingData['_id'] : null,
        'memberId': "",
        'addDate': _dateController.text,
        'description': _selectedDescription,
      };

      if (_selectedDescription == 'පොහොර යෙදීම') {
        updateData['fertilizerType'] = _fertilizerTypeController.text;
        updateData['fertilizerAmount'] =
            double.tryParse(_fertilizerAmountController.text) ?? 0;
        updateData['fertilizerUnit'] = _selectedFertilizerUnit;
      }

      final update = CropUpdate.fromJson(updateData);

      final message = await CropUpdateApi().submitCropUpdate(
        update,
        isUpdate: widget.existingData != null,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  int _daysSinceAddDate(String? addDate) {
    if (addDate == null || addDate.isEmpty) return 0;
    try {
      final start = DateTime.parse(addDate);
      final now = DateTime.now();
      return now.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          ClipPath(
            clipper: ArcClipper(),
            child: Container(
              height: 190,
              color: const Color.fromRGBO(87, 164, 91, 0.8),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Image.asset(
              "assets/icons/leaf.png",
              height: 35,
              width: 35,
            ),
          ),
          Positioned(
            top: 50,
            left: 50,
            right: 0,
            child: Text(
              widget.existingData != null
                  ? 'Edit Crop Update'
                  : 'New Crop Update',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 180),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: GoogleFonts.poppins(
                            fontSize: 15,
                            color: const Color.fromRGBO(87, 164, 91, 0.8)),
                        suffixIcon: IconButton(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_month),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(87, 164, 91, 0.8),
                            width: 2,
                          ),
                        ),
                      ),
                      readOnly: true,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a date'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDescription,
                      items: _cropUpdateOptions.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child:
                              Text(entry.value, style: GoogleFonts.poppins()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDescription = value;
                          _descriptionController.text = value ?? '';
                          if (value != "පොහොර යෙදීම") {
                            _fertilizerTypeController.clear();
                            _fertilizerAmountController.clear();
                            _selectedFertilizerUnit = null;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Crop Update',
                        labelStyle: GoogleFonts.poppins(
                            fontSize: 15,
                            color: const Color.fromRGBO(87, 164, 91, 0.8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(87, 164, 91, 0.8),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Please select a crop update"
                          : null,
                    ),
                    const SizedBox(height: 10),
                    if (_selectedDescription == 'පොහොර යෙදීම') ...[
                      DropdownButtonFormField<String>(
                        initialValue: _fertilizerTypeController.text.isNotEmpty
                            ? _fertilizerTypeController.text
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Fertilizer Type',
                          labelStyle: GoogleFonts.poppins(
                              fontSize: 15,
                              color: const Color.fromRGBO(87, 164, 91, 0.8)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(87, 164, 91, 0.8),
                              width: 2,
                            ),
                          ),
                        ),
                        items: _fertilizerTypeOptions.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child:
                                Text(entry.value, style: GoogleFonts.poppins()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _fertilizerTypeController.text = value ?? '';
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? "Please select fertilizer type"
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _fertilizerAmountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                labelStyle: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color:
                                        const Color.fromRGBO(87, 164, 91, 0.8)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(87, 164, 91, 0.8),
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (_selectedDescription == 'පොහොර යෙදීම') {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter amount';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Enter valid number';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedFertilizerUnit,
                              decoration: InputDecoration(
                                labelText: 'Unit',
                                labelStyle: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color:
                                        const Color.fromRGBO(87, 164, 91, 0.8)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(87, 164, 91, 0.8),
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: _fertilizerUnits.map((unit) {
                                return DropdownMenuItem<String>(
                                  value: unit,
                                  child:
                                      Text(unit, style: GoogleFonts.poppins()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedFertilizerUnit = value;
                                });
                              },
                              validator: (value) {
                                if (_selectedDescription == 'පොහොර යෙදීම' &&
                                    (value == null || value.isEmpty)) {
                                  return 'Select unit';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextFormField(
                      controller: _descriptionController,
                      maxLength: _maxChars,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: GoogleFonts.poppins(
                            fontSize: 15,
                            color: const Color.fromRGBO(87, 164, 91, 0.8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(87, 164, 91, 0.8),
                            width: 2,
                          ),
                        ),
                        counterText: "",
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a description'
                          : null,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "$_charCount/$_maxChars",
                        style: GoogleFonts.poppins(
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(87, 164, 91, 0.8),
                          padding: const EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                widget.existingData != null
                                    ? 'Update'
                                    : 'Submit',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
