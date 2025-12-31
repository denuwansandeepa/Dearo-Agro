// ignore: unused_import
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

Future<void> showDeleteDialog(BuildContext context, String userId) async {
  final parentContext = context; // Save the parent context
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(
          'Confirm Delete Account',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete your account?',
          style: GoogleFonts.poppins(),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('No',
                style: GoogleFonts.poppins(
                    color: const Color.fromRGBO(255, 235, 59, 0.8))),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: Text('Yes', style: GoogleFonts.poppins(color: Colors.red)),
            onPressed: () async {
              try {
                Navigator.of(dialogContext).pop();
                // Use parentContext for navigation!
                await deleteUserProfile(parentContext, userId);
              } catch (e) {
                print('Failed to delete profile: $e');
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> deleteUserProfile(BuildContext context, String userId) async {
  try {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleting profile, please wait...')),
    );

    final userResponse = await http.get(
        Uri.parse("https://dearoagro-backend.onrender.com/api/buyers/$userId"));

    if (userResponse.statusCode != 200) {
      print("Failed to fetch user info: ${userResponse.body}");
      throw Exception("Failed to get user type");
    }

    final userData = jsonDecode(userResponse.body);
    final userType = userData['userType'];

    if (userType == null) {
      throw Exception("User type is null or invalid");
    }

    await http.delete(
        Uri.parse("https://dearoagro-backend.onrender.com/api/buyers/$userId"));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile deleted successfully')),
    );
    await Future.delayed(const Duration(milliseconds: 300));
    Navigator.pushNamedAndRemoveUntil(context, "/signUp", (route) => false);
  } catch (e) {
    print('Failed to delete profile');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
