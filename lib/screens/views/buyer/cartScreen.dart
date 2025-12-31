import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Cartscreen extends StatefulWidget {
  const Cartscreen({super.key});

  @override
  State<Cartscreen> createState() => _CartscreenState();
}

class _CartscreenState extends State<Cartscreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Checkout', style: GoogleFonts.poppins(fontSize: 20)),
        elevation: 0,
      ),
    );
  }
}