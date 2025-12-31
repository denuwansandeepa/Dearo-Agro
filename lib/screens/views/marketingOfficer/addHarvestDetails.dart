import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class AddHarvestScreen extends StatefulWidget {
  const AddHarvestScreen({super.key});

  @override
  _AddHarvestScreenState createState() => _AddHarvestScreenState();
}

class _AddHarvestScreenState extends State<AddHarvestScreen> {
  List farmers = [];
  List<Map<String, dynamic>> crops = [];
  Map<String, dynamic>? selectedFarmer;
  Map<String, dynamic>? selectedCrop;

  final addressController = TextEditingController();
  final totalAmountController = TextEditingController();
  final priceController = TextEditingController();
  DateTime? harvestDate;

  @override
  void initState() {
    super.initState();
    fetchFarmers();
    fetchCrops();
  }

  Future<void> fetchFarmers() async {
    final response = await http.get(
      Uri.parse("https://dearoagro-backend.onrender.com/api/farmers"),
    );

    if (response.statusCode == 200) {
      setState(() {
        farmers = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load farmers")),
      );
    }
  }

  Future<void> fetchCrops() async {
    final response = await http.get(
      Uri.parse("https://dearoagro-backend.onrender.com/api/crops"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        crops = data.map((e) => e as Map<String, dynamic>).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load crops")),
      );
    }
  }

  Future<void> submitStock() async {
    if (selectedFarmer == null || selectedCrop == null || harvestDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Please complete all fields",
              style: GoogleFonts.poppins()),
        ),
      );
      return;
    }

    final body = {
      "memberId": selectedFarmer!["_id"],
      "fullName": selectedFarmer!["fullName"],
      "mobileNumber": selectedFarmer!["mobileNumber"],
      "address": addressController.text,
      "cropId": selectedCrop!["_id"], 
      "cropName": selectedCrop!["name"], 
      "totalAmount": double.tryParse(totalAmountController.text) ?? 0,
      "pricePerKg": double.tryParse(priceController.text) ?? 0,
      "harvestDate": harvestDate!.toIso8601String(),
    };

    final response = await http.post(
      Uri.parse("https://dearoagro-backend.onrender.com/api/stocks"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("✅ Harvest added successfully!",
                style: GoogleFonts.poppins())),
      );
      addressController.clear();
      totalAmountController.clear();
      priceController.clear();
      setState(() {
        selectedFarmer = null;
        selectedCrop = null;
        harvestDate = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("❌ Failed to add harvest", style: GoogleFonts.poppins())),
      );
    }
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: GoogleFonts.poppins(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget buildCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      shadowColor: Colors.green.withOpacity(0.2),
      margin: const EdgeInsets.only(bottom: 22),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800)),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("🌱 Add Harvest",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Farmer Information Card
              buildCard(
                title: "👨‍🌾 Farmer Information",
                child: Column(
                  children: [
                    DropdownButtonFormField<Map<String, dynamic>>(
                      decoration: InputDecoration(
                        labelText: "Select Farmer",
                        labelStyle: GoogleFonts.poppins(),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      items: farmers.map<DropdownMenuItem<Map<String, dynamic>>>(
                          (farmer) {
                        return DropdownMenuItem(
                          value: farmer,
                          child: Text(farmer["fullName"],
                              style: GoogleFonts.poppins()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFarmer = value;
                        });
                      },
                    ),
                    if (selectedFarmer != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade50,
                              Colors.green.shade100
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.green.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("👤 ${selectedFarmer!["fullName"]}",
                                style: GoogleFonts.poppins(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            Text("📞 ${selectedFarmer!["mobileNumber"]}",
                                style: GoogleFonts.poppins(fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    buildTextField(
                        label: "Address", controller: addressController),
                  ],
                ),
              ),

              // Crop Information Card
              buildCard(
                title: "🌾 Crop Information",
                child: Column(
                  children: [
                    DropdownButtonFormField<Map<String, dynamic>>(
                      initialValue: selectedCrop,
                      decoration: InputDecoration(
                        labelText: "Crop Name",
                        labelStyle: GoogleFonts.poppins(),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: crops.map((crop) {
                        return DropdownMenuItem(
                          value: crop,
                          child: Text(crop["name"], style: GoogleFonts.poppins()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCrop = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    buildTextField(
                        label: "Total Amount (kg)",
                        controller: totalAmountController,
                        type: TextInputType.number),
                    const SizedBox(height: 14),
                    buildTextField(
                        label: "Price per Kg",
                        controller: priceController,
                        type: TextInputType.number),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        minimumSize: const Size(double.infinity, 52),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => harvestDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, color: Colors.white),
                      label: Text(
                        harvestDate == null
                            ? "Select Harvest Date"
                            : harvestDate.toString().split(" ")[0],
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

              // Submit button
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  minimumSize: const Size(double.infinity, 55),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: submitStock,
                child: Text("✅ Add Harvest",
                    style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
