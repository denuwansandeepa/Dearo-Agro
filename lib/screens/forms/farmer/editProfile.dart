import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class UpdateProfileScreen extends StatefulWidget {
  final String userId;
  const UpdateProfileScreen({super.key, required this.userId});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  final List<String> _categories = [
    "Farmer",
    "Marketing Officer",
    "Super Admin",
  ];

  bool _isLoading = false;
  String _responseMessage = '';

  // Modify updateProfile to include userType in the GET request
  Future<void> updateProfile() async {
    if (_nameController.text.trim().isEmpty &&
        _mobileController.text.trim().isEmpty &&
        _selectedCategory == null) {
      setState(() => _responseMessage = 'Please fill at least one field');
      return;
    }

    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });

    try {
      // Fetch current user type
      final userResponse = await http.get(Uri.parse(
          'https://dearoagro-backend.onrender.com/api/users/Farmer/${widget.userId}'));

      if (userResponse.statusCode != 200) {
        print("Failed to fetch user info: ${userResponse.body}");
        throw Exception("Failed to get user info");
      }

      final userData = jsonDecode(userResponse.body);
      final currentUserType = userData['userType'];
      if (currentUserType == null) {
        throw Exception("User type is null or invalid");
      }

      final newUserType = _selectedCategory ?? currentUserType;

      final url = Uri.parse(
          'https://dearoagro-backend.onrender.com/api/users/$currentUserType/${widget.userId}');
      final body = json.encode({
        if (_nameController.text.trim().isNotEmpty)
          'fullName': _nameController.text.trim(),
        if (_selectedCategory != null) 'userType': newUserType,
        if (_mobileController.text.trim().isNotEmpty)
          'mobileNumber': _mobileController.text.trim(),
      });

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("API Response Code: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (currentUserType != newUserType) {
          print("User type changed from $currentUserType to $newUserType");
          // Handle user type change if needed
        }
        setState(() => _responseMessage = '✅ Profile updated successfully!');
      } else {
        final errorData = jsonDecode(response.body);
        setState(() => _responseMessage =
            'Update failed: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (error) {
      print("Error during profile update: $error");
      setState(() => _responseMessage = 'Error: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = GoogleFonts.poppins(fontSize: 16);
    final labelStyle = GoogleFonts.poppins(fontWeight: FontWeight.w500);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(87, 164, 91, 0.8),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          ClipPath(
            clipper: ArcClipper(),
            child: Container(
              height: 100,
              color: const Color.fromRGBO(87, 164, 91, 0.8),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: labelStyle,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: inputStyle,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please enter full name'
                              : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'User Type',
                        labelStyle: labelStyle,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category, style: inputStyle),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Please select user type' : null,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _mobileController,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        labelStyle: labelStyle,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: inputStyle,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please enter mobile number'
                              : null,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : updateProfile,
                      icon: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.update, color: Colors.white),
                      label: Text(
                        'Update',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(87, 164, 91, 0.8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _responseMessage,
                      style: GoogleFonts.poppins(
                        color: _responseMessage.contains('✅')
                            ? Colors.green
                            : Colors.red,
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
