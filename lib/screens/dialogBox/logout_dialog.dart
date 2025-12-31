import 'package:farmeragriapp/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> logoutUser(BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Logged out successfully')),
  );
  await AuthService.clearAuthData();
  Navigator.pushReplacementNamed(context, '/signIn');
}

Future<void> showLogOutDialog(BuildContext context, String userId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Confirm Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: <Widget>[
          TextButton(
            child:
                Text('Cancel', style: GoogleFonts.poppins(color: Colors.green)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child:
                Text('Logout', style: GoogleFonts.poppins(color: Colors.red)),
            onPressed: () async {
              Navigator.of(context).pop();
              await logoutUser(context);
            },
          ),
        ],
      );
    },
  );
}
