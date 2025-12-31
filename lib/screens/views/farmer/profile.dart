import 'dart:convert';
import 'dart:io';
import 'package:farmeragriapp/screens/dialogBox/deleteProfile_dialog.dart';
import 'package:farmeragriapp/screens/dialogBox/logout_dialog.dart';
import 'package:farmeragriapp/screens/forms/farmer/changePassword.dart';
import 'package:farmeragriapp/screens/forms/farmer/editProfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart'
    as custom_clippers;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String userType;

  const ProfileScreen(
      {super.key, required this.userId, required this.userType});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Loading...';
  String role = 'Loading...';
  String profileImage = "";
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final String apiUrl = "https://dearoagro-backend.onrender.com/api/farmers";

  @override
  void initState() {
    super.initState();
    print(
        "ProfileScreen initialized with userId: ${widget.userId}, userType: ${widget.userType}");
    fetchUserProfile();
  }

  // Show user profile
  Future<void> fetchUserProfile() async {
    try {
      print("Fetching user info for userId: ${widget.userId}");

      final response = await http.get(Uri.parse("$apiUrl/${widget.userId}"));

      if (response.statusCode == 404) {
        setState(() {
          userName = 'User not found';
          role = 'Unknown';
        });
        return;
      }

      if (response.statusCode != 200) {
        throw Exception(
            "Failed to load user info. Code: ${response.statusCode}");
      }

      final data = jsonDecode(response.body);
      setState(() {
        userName = data['fullName'] ?? 'No name';
        role = data['userType'] ?? 'Unknown';
        profileImage = data['profileImage'] ?? "";
      });
      print(
          "Updated state: userName=$userName, role=$role, profileImage=$profileImage");
    } catch (e) {
      print("Error fetching profile: $e");
      setState(() {
        userName = "Error loading profile";
        role = "Unknown";
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File selected = File(pickedFile.path);
      setState(() {
        _imageFile = selected;
      });

      final bytes = await selected.readAsBytes();
      String base64Image = base64Encode(bytes);

      await updateProfileImage(base64Image);
    }
  }

  // Update updateProfileImage to include userType
  Future<void> updateProfileImage(String profileImage) async {
    try {
      final url = Uri.parse("$apiUrl/${widget.userId}");
      final body = jsonEncode({'profileImage': profileImage});

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        await fetchUserProfile();
        setState(() => _imageFile = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update image')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile() async {
    final response = await http.delete(
      Uri.parse("$apiUrl/${widget.userId}"),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile deleted successfully')),
      );
      Navigator.pushReplacementNamed(context, "/signIn");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: custom_clippers.ArcClipper(),
                  child: Container(
                    height: 190,
                    color: const Color.fromRGBO(87, 164, 91, 0.8),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (profileImage.isNotEmpty
                                ? MemoryImage(base64Decode(
                                    profileImage.contains(',')
                                        ? profileImage.split(',').last
                                        : profileImage))
                                : null),
                        child: _imageFile == null && profileImage.isEmpty
                            ? const Icon(Icons.account_circle,
                                size: 100, color: Colors.white)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.edit,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  role,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.yellow[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdateProfileScreen(userId: widget.userId),
                        ),
                      );
                    },
                  ),
                  const Divider(thickness: 1, color: Colors.grey),
                  _buildProfileOption(
                    icon: Icons.delete,
                    title: 'Delete Profile',
                    onTap: () {
                      showDeleteProfileDialog(context, widget.userId);
                    },
                  ),
                  const Divider(thickness: 1, color: Colors.grey),
                  _buildProfileOption(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordScreen(
                            userId: widget.userId,
                            userType: '',
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(thickness: 1, color: Colors.grey),
                  _buildProfileOption(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      showLogOutDialog(context, widget.userId);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromRGBO(87, 164, 91, 0.8)),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
      onTap: onTap,
    );
  }
}
