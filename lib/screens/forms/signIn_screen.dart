import 'dart:convert';
import 'package:farmeragriapp/api/auth_api.dart';
import 'package:farmeragriapp/models/user_model.dart';
import 'package:farmeragriapp/screens/dialogBox/welcomBox.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/gestures.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  bool _isPasswordVisible = false;
  String? _selectedUserType;

  final List<String> _userTypes = [
    "Farmer",
    "Marketing Officer",
    "Buyer",
  ];

  Future<void> signIn() async {
    if (mobileController.text.isEmpty ||
        passwordController.text.isEmpty ||
        _selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all fields and select a user type")),
      );
      return;
    }

    User user = User(
      mobileNumber: mobileController.text,
      password: passwordController.text,
      userType: _selectedUserType!,
    );

    try {
      final response = await AuthApi.signIn(user);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String? token = data['token'];
        final String? userType = data['userType'];

        if (token != null) {
          final decodedToken = JwtDecoder.decode(token);
          final String? userId = decodedToken['id'];

          if (userId != null) {
            await storage.write(key: "userId", value: userId);
            await storage.write(key: "authToken", value: token);
            await storage.write(key: "userType", value: userType);
            print("User ID saved: $userId");

            if (userType == 'Farmer') {
              showWelcomeDialog(context, userId);
            } else if (userType == 'Marketing Officer') {
              Navigator.pushNamed(context, "/officerDashboard");
            } else if (userType == 'Buyer') {
              Navigator.pushNamed(context, "/buyerDashboard");
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      "Access restricted to Farmers, Marketing Officers, and Buyers only"),
                ),
              );
            }
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-in failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
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
                  top: arcHeight - 30,
                  bottom: 24,
                ),
                child: SizedBox(
                  width: cardWidth,
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 51, 162, 56)
                                .withOpacity(0.80), // Top color with opacity
                            const Color.fromARGB(2, 246, 247, 246)
                                .withOpacity(0.60), // Bottom color with opacity
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
                              "assets/images/SignIn.png",
                              width: logoSize,
                              height: logoSize,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                fontSize: headerFontSize,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 7, 7, 7),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildTextField(mobileController, "Mobile Number",
                                isDesktop, isTablet),
                            _buildPasswordField(passwordController, "Password",
                                isDesktop, isTablet),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedUserType,
                              decoration: InputDecoration(
                                labelText: "Select User Type",
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: const Color.fromARGB(204, 0, 0, 0),
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
                              items: _userTypes.map((String userType) {
                                return DropdownMenuItem<String>(
                                  value: userType,
                                  child: Text(userType,
                                      style: GoogleFonts.poppins(fontSize: 15)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedUserType = newValue;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 5, 40, 6),
                                  padding: EdgeInsets.symmetric(
                                      vertical: buttonPadding),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: signIn,
                                child: Text(
                                  "Sign In",
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
                                text: "Don't have an account? ",
                                style: GoogleFonts.poppins(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: "Sign Up",
                                    style: GoogleFonts.poppins(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushNamed(context, "/signUp");
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
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: fontSize,
            color: const Color.fromARGB(204, 0, 0, 0),
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
          labelStyle: GoogleFonts.poppins(
            fontSize: fontSize,
            color: const Color.fromARGB(204, 0, 0, 0),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
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
