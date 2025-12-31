import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadSoilTestReportScreen extends StatefulWidget {
  final String farmerId;

  const UploadSoilTestReportScreen({super.key, required this.farmerId});

  @override
  State<UploadSoilTestReportScreen> createState() => _UploadSoilTestReportScreenState();
}

class _UploadSoilTestReportScreenState extends State<UploadSoilTestReportScreen> {
  File? selectedFile;
  bool isUploading = false;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> uploadFile() async {
    if (selectedFile == null) return;

    setState(() => isUploading = true);

    // TODO: Upload logic to backend using API and widget.farmerId
    await Future.delayed(const Duration(seconds: 2)); // Simulating upload

    setState(() => isUploading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Soil test report uploaded successfully')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Upload Soil Test Report',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text("Choose File"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F7B3F),
                  foregroundColor: Colors.white,
                ),
              ),
              if (selectedFile != null) ...[
                const SizedBox(height: 20),
                Text('Selected File: ${selectedFile!.path.split('/').last}', style: GoogleFonts.poppins()),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: isUploading ? null : uploadFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F7B3F),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Upload Report", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
