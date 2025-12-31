// ignore: unused_import
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

Future<void> showDeleteProfileDialog(
    BuildContext context, String userId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
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
            child: Text('No', style: GoogleFonts.poppins(color: Colors.green)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Yes', style: GoogleFonts.poppins(color: Colors.red)),
            onPressed: () async {
              try {
                Navigator.of(context).pop();
                await deleteUserProfile(context, userId); // Then delete
              } catch (e) {
                print('Failed to delete profile: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
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
    // Show a loading message while deleting
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleting profile, please wait...')),
    );

    // Fetch user type dynamically
    final userResponse = await http.get(Uri.parse(
        "https://dearoagro-backend.onrender.com/api/users/Farmer/$userId"));

    if (userResponse.statusCode != 200) {
      print("Failed to fetch user info: ${userResponse.body}");
      throw Exception("Failed to get user type");
    }

    final userData = jsonDecode(userResponse.body);
    final userType = userData['userType'];

    if (userType == null) {
      throw Exception("User type is null or invalid");
    }

    // Delete user profile
    final response = await http.delete(Uri.parse(
        "https://dearoagro-backend.onrender.com/api/users/$userType/$userId"));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile deleted successfully')),
      );
      Navigator.pushReplacementNamed(context, "/signIn");
    } else {
      print("Failed to delete profile: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete profile')),
      );
    }
  } catch (e) {
    print('Failed to delete profile: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
