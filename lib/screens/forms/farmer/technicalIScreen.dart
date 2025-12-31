import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TechnicalIScreen extends StatefulWidget {
  const TechnicalIScreen({super.key});

  @override
  State<TechnicalIScreen> createState() => _TechnicalIScreenState();
}

class _TechnicalIScreenState extends State<TechnicalIScreen> {
  DateTime? _selectedDate;
  File? _selectedImage;
  File? _selectedDocument;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final String _baseUrl = "https://dearoagro-backend.onrender.com/api";
  final String _farmerId ="12345"; 
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (await file.exists()) {
          setState(() {
            _selectedImage = file;
            _imageController.text = path.basename(pickedFile.path);
          });
        }
      }
    } catch (e) {
      _showSnackBar('Image picker error: ${e.toString()}');
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (await file.exists()) {
          setState(() {
            _selectedDocument = file;
            _documentController.text = result.files.single.name;
          });
        }
      }
    } catch (e) {
      _showSnackBar('Document picker error: ${e.toString()}');
    }
  }

  Future<void> _submitInquiry() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _dateController.text.isEmpty) {
      _showSnackBar('Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$_baseUrl/tinquiry'))
            ..fields['title'] = _titleController.text
            ..fields['description'] = _descriptionController.text
            ..fields['date'] = _dateController.text
            ..fields['farmerId'] = _farmerId;

      if (_selectedImage != null && await _selectedImage!.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagePath',
            _selectedImage!.path,
            filename: path.basename(_selectedImage!.path),
          ),
        );
      }

      if (_selectedDocument != null && await _selectedDocument!.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'documentPath',
            _selectedDocument!.path,
            filename: path.basename(_selectedDocument!.path),
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        _showSnackBar('Inquiry submitted successfully');
        _resetForm();
      } else {
        final errorData = json.decode(responseBody);
        throw Exception(errorData['message'] ?? 'Unknown server error');
      }
    } catch (e) {
      _showSnackBar('Submission error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchInquiries() async {
    setState(() => _isLoading = true);

    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/tinquiries/farmer/$_farmerId'));
      if (response.statusCode == 200) {
        final List<dynamic> inquiries = json.decode(response.body);
        print('Fetched inquiries: $inquiries'); // Debug log
        // TODO: Update UI to display inquiries
      } else {
        throw Exception('Failed to fetch inquiries');
      }
    } catch (e) {
      _showSnackBar('Error fetching inquiries: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _dateController.clear();
    _imageController.clear();
    _documentController.clear();
    setState(() {
      _selectedImage = null;
      _selectedDocument = null;
      _selectedDate = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            Image.asset(
              "assets/images/general_image.png",
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10),
              child: _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        ClipPath(
          clipper: ArcClipper(),
          child: Container(
            height: 190,
            color: const Color.fromRGBO(87, 164, 91, 0.8),
          ),
        ),
        Positioned(
          top: 30,
          left: 10,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        Positioned(
          top: 40,
          left: 50,
          child: Text(
            "Inquiry Submision",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
          top: 30,
          right: 20,
          child: IconButton(
            onPressed: () => Navigator.pushNamed(context, "/myTechnical"),
            icon: const Icon(Icons.collections_bookmark, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField(_titleController, "Title"),
        const SizedBox(height: 10),
        _buildTextField(_descriptionController, "Description", maxLines: 2),
        const SizedBox(height: 10),
        _buildDateField(),
        const SizedBox(height: 10),
        _buildFileField(_imageController, "Upload Image (optional)",
            Icons.image, _pickImage),
        const SizedBox(height: 10),
        _buildFileField(_documentController, "Upload Document (optional)",
            Icons.attach_file, _pickDocument),
        const SizedBox(height: 20),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
            fontSize: 14, color: const Color.fromRGBO(87, 164, 91, 0.8)),
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
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: "Date",
        labelStyle: GoogleFonts.poppins(
            fontSize: 14, color: const Color.fromRGBO(87, 164, 91, 0.8)),
        suffixIcon: IconButton(
          onPressed: _pickDate,
          icon: const Icon(Icons.calendar_month,
              color: Color.fromRGBO(87, 164, 91, 0.8)),
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
    );
  }

  Widget _buildFileField(TextEditingController controller, String label,
      IconData icon, VoidCallback onPressed) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
            fontSize: 14, color: const Color.fromRGBO(87, 164, 91, 0.8)),
        suffixIcon: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: const Color.fromRGBO(87, 164, 91, 0.8)),
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
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(87, 164, 91, 0.8),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: _isLoading ? null : _submitInquiry,
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              "Submit",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}
