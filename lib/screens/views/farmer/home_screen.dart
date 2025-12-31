import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Flag to control the splash screen
  bool _isSplashScreenVisible = true;

  @override
  void initState() {
    super.initState();

    // Set up a timer to hide the splash screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isSplashScreenVisible = false; // Hide splash screen
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background after splash screen
      body: _isSplashScreenVisible
          ? _buildSplashScreen() // Show splash screen
          : _buildMainScreen(), // Show main screen (logo & button)
    );
  }

 
  Widget _buildSplashScreen() {
    return Center(
      child: Image.asset(
        'assets/images/paddy.png', // Your background image
        fit: BoxFit.cover, // Cover the entire screen
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  // Main screen with logo and "Get Started" button
  Widget _buildMainScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: screenWidth * 0.6,
          ),
          const SizedBox(height: 100),
          SizedBox(
            width: screenWidth * 0.6,
            height: screenHeight * 0.06,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 92, 155, 94),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/signUp");
              },
              child: const Text(
                "Get Started",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
