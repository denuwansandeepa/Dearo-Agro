import 'package:farmeragriapp/api/expense_api.dart';
import 'package:farmeragriapp/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class AddExpense extends StatefulWidget {
  final dynamic existingData;

  const AddExpense({super.key, this.existingData});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _storage = const FlutterSecureStorage();
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _expenseController = TextEditingController();

  final int _maxChars = 50;
  int _charCount = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Keep this list in Sinhala as requested
  final List<String> _expenseDescriptions = [
    "බිම සකස් කිරීම",
    "බීජ තේරීම සහ බීජ වගාව",
    "රෝපණය (වගා කිරීම)",
    "පොහොර යෙදීම",
    "ජල සපයීම (පෙරලීම)",
    "වාලි කිරීම සහ නියමිත පාලනය",
    "වර්ධනය පරික්ෂා කිරීම",
    "අස්වනු තක්සේරු කිරීම",
    "අස්වනු කිරීම",
    "අස්වනු ගබඩා කිරීම",
    "අස්වනු බෙදාහැරීම"
  ];

  String? _selectedDescription;

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
      _descriptionController.text = widget.existingData['description'] ?? '';
      _dateController.text = widget.existingData['addDate'] ?? '';
      _expenseController.text =
          widget.existingData['expense']?.toString() ?? '';
      _parseExistingDate();

      // Set dropdown if matches
      if (_expenseDescriptions.contains(widget.existingData['description'])) {
        _selectedDescription = widget.existingData['description'];
      }
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
    _expenseController.dispose();
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
      final userId = await _storage.read(key: "userId");
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      final expense = Expense(
        id: widget.existingData?['_id'],
        memberId: userId,
        addDate: _dateController.text,
        description: _descriptionController.text,
        expense: _expenseController.text,
      );

      final api = ExpenseApi();

      final message = widget.existingData != null
          ? await api.updateExpense(expense)
          : await api.submitExpense(expense);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
            top: 50,
            left: 50,
            child: Text(
              widget.existingData != null
                  ? "Edit Cultivational Expense"
                  : "New Cultivational Expense",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Date",
                        labelStyle: GoogleFonts.poppins(color: Colors.black),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: _pickDate,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(87, 164, 91, 0.8),
                              width: 2),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Please select a date"
                          : null,
                    ),
                    const SizedBox(height: 10),
                    // Dropdown for description (displays Sinhala options)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDescription,
                      items: _expenseDescriptions
                          .map((desc) => DropdownMenuItem(
                                value: desc,
                                child: Text(desc, style: GoogleFonts.poppins()),
                              ))
                          .toList(),
                      decoration: InputDecoration(
                        labelText: "Description about crop expense",
                        labelStyle: GoogleFonts.poppins(color: Colors.black),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(87, 164, 91, 0.8),
                              width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedDescription = value;
                          _descriptionController.text = value ?? '';
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? "Please select a description"
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _expenseController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Expense Amount (Rs.)",
                        labelStyle: GoogleFonts.poppins(color: Colors.black),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(87, 164, 91, 0.8),
                              width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter an amount";
                        }
                        if (double.tryParse(value) == null) {
                          return "Enter a valid number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
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
                                    ? "Update"
                                    : "Submit",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
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
