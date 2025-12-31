import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart'
    as custom_clippers;
import 'package:farmeragriapp/api/farmer_api.dart';
import 'package:farmeragriapp/models/farmer_model.dart';

class CreateFarmerScreen extends StatefulWidget {
  const CreateFarmerScreen({super.key});

  @override
  State<CreateFarmerScreen> createState() => _CreateFarmerScreenState();
}

class _CreateFarmerScreenState extends State<CreateFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedBranch; 
  bool isLoading = false;
  bool isPasswordVisible = false;

  final List<String> branches = [
    "Head Office - Colombo",
    "Badulla",
    "Welimada",
    "Dambulla",
    "Mannar",
    "Chenkalady",
    "Muthur",
    "Nelliady",
    "Mahiyanganaya",
    "Polonnaruwa",
    "Thissamaharama",
    "Trincomalee",
    "Vavunathivu",
    "Kinniya",
    "Chunnakam",
    "Kaluwanchikudy",
    "Dehiattakandiya",
    "Batticaloa",
    "Vavuniya",
    "Ampara",


  ];

  Future<void> createFarmer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FarmerApi.createFarmer(
        Farmer(
          id: '',
          fullName: fullNameController.text,
          mobileNumber: mobileNumberController.text,
          password: passwordController.text,
          branchName: selectedBranch,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer created successfully')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      print('Error creating farmer: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create farmer')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double arcHeight = 250.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background5.png",
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              ClipPath(
                clipper: custom_clippers.ArcClipper(),
                child: Container(
                  height: arcHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(119, 153, 161, 1),
                        Color.fromRGBO(2, 75, 5, 0.69),
                        Color.fromRGBO(119, 153, 161, 1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Register New Farmer",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: fullNameController,
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(87, 164, 91, 0.8),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter the full name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: mobileNumberController,
                          decoration: InputDecoration(
                            labelText: "Mobile Number",
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(87, 164, 91, 0.8),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter the mobile number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(87, 164, 91, 0.8),
                                width: 2,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter the password";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedBranch,
                          items: branches.map((branch) {
                            return DropdownMenuItem(
                              value: branch,
                              child: Text(branch,
                                  style: GoogleFonts.poppins(fontSize: 16)),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: "Select Branch",
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(87, 164, 91, 0.8),
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedBranch = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select a branch";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: createFarmer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(2, 75, 5, 0.69),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Create Farmer",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}
