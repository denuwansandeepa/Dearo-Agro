import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StockFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingStock; // Pass data when updating

  const StockFormScreen({super.key, this.existingStock, required farmerId, required Map<String, dynamic> harvest});

  @override
  _StockFormScreenState createState() => _StockFormScreenState();
}

class _StockFormScreenState extends State<StockFormScreen> {
  List farmers = [];
  Map<String, dynamic>? selectedFarmer;

  final addressController = TextEditingController();
  final totalAmountController = TextEditingController();
  final priceController = TextEditingController();
  DateTime? harvestDate;
  String? selectedCrop;

  // Sinhala crop list
  final List<String> _cropNames = [
    "වී", "ගම්මුදු", "බඩ ඉරිඟු", "කඩල", "සුදු කවුපි", "රතු කවුපි", "කලු කවුපි",
    "මුං ඇට", "අල", "රතු අල", "කැරට්", "රාබු", "කෙසෙල්", "අඹ", "මිදි",
    "තක්කාලි", "ගෝවා", "පිපිඤ්ඤා", "ලූනු", "තේ", "කෝපි", "කෝකෝ"
  ];

  @override
  void initState() {
    super.initState();
    fetchFarmers();

    if (widget.existingStock != null) {
      final stock = widget.existingStock!;
      addressController.text = stock["address"] ?? "";
      totalAmountController.text = stock["totalAmount"].toString();
      priceController.text = stock["pricePerKg"].toString();
      selectedCrop = stock["cropName"];
      harvestDate = DateTime.tryParse(stock["harvestDate"]);
    }
  }

  Future<void> fetchFarmers() async {
    final response = await http.get(
      Uri.parse("https://dearoagro-backend.onrender.com/api/farmers"),
    );

    if (response.statusCode == 200) {
      setState(() {
        farmers = json.decode(response.body);
        // pre-select farmer when updating
        if (widget.existingStock != null) {
          selectedFarmer = farmers.firstWhere(
            (f) => f["_id"] == widget.existingStock!["memberId"],
            orElse: () => null,
          );
        }
      });
    }
  }

  Future<void> saveStock() async {
    if (selectedFarmer == null || selectedCrop == null || harvestDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please complete all fields")),
      );
      return;
    }

    final body = {
      "memberId": selectedFarmer!["_id"],
      "fullName": selectedFarmer!["fullName"],
      "mobileNumber": selectedFarmer!["mobileNumber"],
      "address": addressController.text,
      "cropName": selectedCrop ?? "",
      "totalAmount": double.tryParse(totalAmountController.text) ?? 0,
      "pricePerKg": double.tryParse(priceController.text) ?? 0,
      "harvestDate": harvestDate!.toIso8601String(),
    };

    final isUpdating = widget.existingStock != null;
    final url = isUpdating
        ? "https://dearoagro-backend.onrender.com/api/stocks/${widget.existingStock!["_id"]}"
        : "https://dearoagro-backend.onrender.com/api/stocks";

    final response = await (isUpdating
        ? http.put(Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: json.encode(body))
        : http.post(Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: json.encode(body)));

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isUpdating
                ? "✅ Harvest updated successfully!"
                : "✅ Harvest added successfully!")),
      );
      Navigator.pop(context, true); // return success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to save harvest")),
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
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget buildCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = widget.existingStock != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isUpdating ? "Update Harvest" : "Add Harvest"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Farmer Info
              buildCard(
                title: "👨‍🌾 Farmer Information",
                child: Column(
                  children: [
                    DropdownButtonFormField(
                      initialValue: selectedFarmer,
                      decoration: InputDecoration(
                        labelText: "Select Farmer",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: farmers.map((farmer) {
                        return DropdownMenuItem(
                          value: farmer,
                          child: Text(farmer["fullName"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFarmer = value as Map<String, dynamic>;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    buildTextField(
                        label: "Address", controller: addressController),
                  ],
                ),
              ),

              // Crop Info
              buildCard(
                title: "🌾 Crop Information",
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedCrop,
                      decoration: InputDecoration(
                        labelText: "Crop Name",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _cropNames.map((crop) {
                        return DropdownMenuItem(
                          value: crop,
                          child: Text(crop),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCrop = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    buildTextField(
                        label: "Total Amount (kg)",
                        controller: totalAmountController,
                        type: TextInputType.number),
                    const SizedBox(height: 12),
                    buildTextField(
                        label: "Price per Kg",
                        controller: priceController,
                        type: TextInputType.number),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: harvestDate ?? DateTime.now(),
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
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: saveStock,
                child: Text(isUpdating ? "🔄 Update Harvest" : "✅ Add Harvest",
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
