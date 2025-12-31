import 'package:farmeragriapp/screens/views/farmer/farmer_dashbaord.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showWelcomeDialog(BuildContext context, String userId) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFF8E1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.amber,
                  size: 54,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Welcome!",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF57A45B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Sign in successful!",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Redirecting to farmer dashboard...",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: Colors.grey[200],
                color: const Color(0xFF57A45B),
              ),
            ],
          ),
        ),
      );
    },
  );

  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FarmerDashboard(userId: userId),
      ),
    );
  });
}
