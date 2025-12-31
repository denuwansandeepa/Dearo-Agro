import 'package:farmeragriapp/api/auth_api.dart';
import 'package:farmeragriapp/models/user_model.dart';
import 'package:farmeragriapp/screens/dialogBox/success_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = false;
  String? _selectedCategory;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final List<String> _categories = [
    "Farmer",
    "Marketing Officer",
    "Buyer",
  ];

  Future<void> signUp() async {
    if (nameController.text.isEmpty ||
        mobileController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all fields and select a category")),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    User newUser = User(
      fullName: nameController.text,
      mobileNumber: mobileController.text,
      password: passwordController.text,
      userType: _selectedCategory,
    );

    final response = await AuthApi.signUp(newUser);

    if (response.statusCode == 200 || response.statusCode == 201) {
      showSuccessDialog(context);
      nameController.clear();
      mobileController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      setState(() {
        _selectedCategory = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing up: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    final padding = isDesktop
        ? 120.0
        : isTablet
            ? 50.0
            : 16.0;
    final cardPadding = isDesktop
        ? 48.0
        : isTablet
            ? 32.0
            : 18.0;
    final headerFontSize = isDesktop
        ? 32.0
        : isTablet
            ? 26.0
            : 22.0;
    final arcHeight = isDesktop
        ? 220.0
        : isTablet
            ? 180.0
            : 150.0;
    final logoSize = isDesktop
        ? 180.0
        : isTablet
            ? 140.0
            : 100.0;
    final buttonFontSize = isDesktop
        ? 20.0
        : isTablet
            ? 18.0
            : 16.0;
    final buttonPadding = isDesktop
        ? 22.0
        : isTablet
            ? 18.0
            : 14.0;
    final cardWidth = isDesktop ? 500.0 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: padding,
                  right: padding,
                  top: arcHeight + 12,
                  bottom: 24,
                ),
                child: SizedBox(
                  width: cardWidth,
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 51, 162, 56).withOpacity(0.80),
                            const Color.fromARGB(2, 246, 247, 246)
                                .withOpacity(0.60),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: cardPadding, vertical: cardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/signup.png",
                              width: logoSize,
                              height: logoSize,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Sign Up",
                              style: GoogleFonts.poppins(
                                fontSize: headerFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: InputDecoration(
                                  labelText: "Select Category",
                                  labelStyle: GoogleFonts.poppins(
                                      fontSize: 15, color: Colors.black),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color.fromRGBO(87, 164, 91, 0.8),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items: _categories.map((String category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category,
                                        style:
                                            GoogleFonts.poppins(fontSize: 15)),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                },
                              ),
                            ),
                            _buildTextField(nameController, "Full Name",
                                isDesktop, isTablet),
                            _buildTextField(mobileController, "Mobile Number",
                                isDesktop, isTablet),
                            _buildPasswordField(passwordController, "Password",
                                isDesktop, isTablet),
                            _buildPasswordField(confirmPasswordController,
                                "Confirm Password", isDesktop, isTablet),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 15, 59, 18),
                                  padding: EdgeInsets.symmetric(
                                      vertical: buttonPadding),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: signUp,
                                child: Text(
                                  "Sign Up",
                                  style: GoogleFonts.poppins(
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: GoogleFonts.poppins(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: "Sign In",
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushNamed(context, "/signIn");
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      bool isDesktop, bool isTablet) {
    final fontSize = isDesktop
        ? 18.0
        : isTablet
            ? 16.0
            : 15.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              GoogleFonts.poppins(fontSize: fontSize, color: Colors.black),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color.fromRGBO(87, 164, 91, 0.8),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool isDesktop, bool isTablet) {
    final fontSize = isDesktop
        ? 18.0
        : isTablet
            ? 16.0
            : 15.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              GoogleFonts.poppins(fontSize: fontSize, color: Colors.black),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color.fromRGBO(87, 164, 91, 0.8),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
