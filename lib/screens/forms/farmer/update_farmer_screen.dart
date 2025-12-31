import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart'
    as custom_clippers;
import 'package:farmeragriapp/api/farmer_api.dart';
import 'package:farmeragriapp/models/farmer_model.dart';

class UpdateFarmerScreen extends StatefulWidget {
  const UpdateFarmerScreen({super.key});

  @override
  State<UpdateFarmerScreen> createState() => _UpdateFarmerScreenState();
}

class _UpdateFarmerScreenState extends State<UpdateFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final farmer = ModalRoute.of(context)!.settings.arguments as Farmer;
    fullNameController.text = farmer.fullName;
    mobileNumberController.text = farmer.mobileNumber;
  }

  Future<void> updateFarmer(String id) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FarmerApi.updateFarmer(
        id,
        Farmer(
          id: id,
          fullName: fullNameController.text,
          mobileNumber: mobileNumberController.text,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer updated successfully')),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } catch (error) {
      print('Error updating farmer: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update farmer')),
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
                      "Update Farmer",
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
                        const SizedBox(height: 24),
                        isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () {
                                  final farmer = ModalRoute.of(context)!.settings.arguments as Farmer;
                                  updateFarmer(farmer.id);
                                },
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
                                  "Update Farmer",
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
