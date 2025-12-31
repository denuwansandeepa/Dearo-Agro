import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for zoom in and zoom out
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start the splash sequence
    Timer(const Duration(seconds: 3), _showLogo);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showLogo() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LogoScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/images/Dearo Agro.png',
            width: screenWidth * 0.4, // 40% of screen width
            height: screenHeight * 0.2, // 20% of screen height
          ),
        ),
      ),
    );
  }
}

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to sign-in screen after showing the logo
    Timer(const Duration(seconds: 3), _navigateToSignIn);
  }

  void _navigateToSignIn() {
    Navigator.pushReplacementNamed(context, "/signIn");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logo.png', // Replace with your app logo path
          width: 300,
          height: 300,
        ),
      ),
    );
  }
}
