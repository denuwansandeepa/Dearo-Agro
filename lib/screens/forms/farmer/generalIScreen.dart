import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeneralIScreen extends StatefulWidget {
  const GeneralIScreen({super.key});

  @override
  State<GeneralIScreen> createState() => _GeneralIScreenState();
}

class _GeneralIScreenState extends State<GeneralIScreen> {
  // ignore: unused_field
  DateTime? _selectedDate;
  File? _selectedImage;
  File? _selectedDocument;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final String _baseUrl = "https://dearoagro-backend.onrender.com/api";
  bool _isLoading = false;

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

     if (pickedDate != null) {  // <-- Check for null
    setState(() {
      _selectedDate = pickedDate;
      _dateController.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    });
  }
}

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageController.text = path.basename(pickedFile.path);
      });
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedDocument = File(result.files.single.path!);
        _documentController.text = result.files.single.name;
        print('Picked file name: ${result.files.single.name}'); 

      });
    }
  }

  Future<void> _submitInquiry() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$_baseUrl/inquiry'));

      // Add text fields
      request.fields['title'] = _titleController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['date'] = _dateController.text;

      // Add image file if selected
      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagePath',
            _selectedImage!.path,
            filename: path.basename(_selectedImage!.path),
          ),
        );
      }

      // Add document file if selected
      if (_selectedDocument != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'documentPath',
            _selectedDocument!.path,
            filename: path.basename(_selectedDocument!.path),
          ),
        );
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inquiry submitted successfully')),
        );
        _resetForm();
      } else {
        final errorData = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${errorData['message'] ?? 'Unknown error'}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
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
                    "General Inquiry",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                ),
                Positioned(
                    top: 30,
                    right: 20,
                    child: IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/myGeneral");
                        },
                        icon: const Icon(Icons.collections_bookmark))),
              ],
            ),
            const SizedBox(height: 10),
            Image.asset(
              "assets/images/general.png",
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Description",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: "Date",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 14,
                      ),
                      suffixIcon: IconButton(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month,
                            color: Color.fromRGBO(87, 164, 91, 0.8)),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _imageController,
                    decoration: InputDecoration(
                      labelText: "Upload Image (optional)",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 14,
                      ),
                      suffixIcon: IconButton(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image,
                            color: Color.fromRGBO(87, 164, 91, 0.8)),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _documentController,
                    decoration: InputDecoration(
                      labelText: "Upload Document (optional)",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 14,
                      ),
                      suffixIcon: IconButton(
                        onPressed: _pickDocument,
                        icon: const Icon(Icons.attach_file,
                            color: Color.fromRGBO(87, 164, 91, 0.8)),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(87, 164, 91, 0.8),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _isLoading ? null : _submitInquiry,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Submit",
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
