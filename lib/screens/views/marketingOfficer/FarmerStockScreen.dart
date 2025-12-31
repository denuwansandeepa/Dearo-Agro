import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FarmerStockScreen extends StatefulWidget {
  const FarmerStockScreen({super.key});

  @override
  _FarmerStockScreenState createState() => _FarmerStockScreenState();
}

class _FarmerStockScreenState extends State<FarmerStockScreen> {
  List farmers = [];
  Map<String, dynamic>? selectedFarmer;
  List stocks = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchFarmers();
  }

  Future<void> fetchFarmers() async {
    final response = await http.get(
      Uri.parse("https://dearoagro-backend.onrender.com/api/farmers"),
    );

    if (response.statusCode == 200) {
      setState(() {
        farmers = json.decode(response.body);
      });
    }
  }

  Future<void> fetchStocks(String farmerId) async {
    setState(() {
      isLoading = true;
      stocks = [];
    });

    final response = await http.get(
      Uri.parse(
        "https://dearoagro-backend.onrender.com/api/stocks/fetch/$farmerId?t=${DateTime.now().millisecondsSinceEpoch}",
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        stocks = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to fetch stocks")),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> deleteStock(String stockId) async {
    final response = await http.delete(
      Uri.parse("https://dearoagro-backend.onrender.com/api/stocks/delete/$stockId"),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Stock deleted successfully")),
      );
      if (selectedFarmer != null) {
        fetchStocks(selectedFarmer!["_id"]);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to delete stock")),
      );
    }
  }

  Future<void> editStock(Map<String, dynamic> stock) async {
    TextEditingController cropNameCtrl = TextEditingController(text: stock["cropName"]);
    TextEditingController totalAmountCtrl = TextEditingController(text: stock["totalAmount"].toString());
    TextEditingController pricePerKgCtrl = TextEditingController(text: stock["pricePerKg"].toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("✏️ Edit Stock"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: cropNameCtrl,
                  decoration: const InputDecoration(labelText: "Crop Name"),
                ),
                TextField(
                  controller: totalAmountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Total Amount (kg)"),
                ),
                TextField(
                  controller: pricePerKgCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price per Kg"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Update"),
              onPressed: () async {
                final newTotal = int.tryParse(totalAmountCtrl.text) ?? stock["totalAmount"];
                final oldTotal = (stock["totalAmount"] as num).toInt();
                final oldCurrent = (stock["currentAmount"] as num?)?.toInt() ?? oldTotal;
                final delta = newTotal - oldTotal;

                num newCurrent = oldCurrent + delta;
                if (newCurrent < 0) newCurrent = 0;
                if (newCurrent > newTotal) newCurrent = newTotal;

                final response = await http.put(
                  Uri.parse("https://dearoagro-backend.onrender.com/api/stocks/update"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "id": stock["_id"],
                    "cropName": cropNameCtrl.text,
                    "totalAmount": newTotal,
                    "pricePerKg": double.tryParse(pricePerKgCtrl.text) ?? stock["pricePerKg"],
                    "currentAmount": newCurrent,
                  }),
                );

                Navigator.pop(context);

                if (response.statusCode == 200) {
                  setState(() {
                    stock["cropName"] = cropNameCtrl.text;
                    stock["totalAmount"] = newTotal;
                    stock["pricePerKg"] = double.tryParse(pricePerKgCtrl.text) ?? stock["pricePerKg"];
                    stock["currentAmount"] = newCurrent;
                  });
                  if (selectedFarmer != null) fetchStocks(selectedFarmer!["_id"]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Stock updated successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❌ Failed to update stock")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildStockCard(Map<String, dynamic> stock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 7, 42, 7), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          "🌾 ${stock["cropName"]}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text("📦 Total: ${stock["totalAmount"]} kg", style: const TextStyle(color: Colors.white70)),
            Text("✅ Available: ${stock["currentAmount"]} kg", style: const TextStyle(color: Colors.white70)),
            Text("💰 Rs. ${stock["pricePerKg"]}/kg", style: const TextStyle(color: Colors.white70)),
            Text("📅 ${DateTime.parse(stock["harvestDate"]).toLocal().toString().split(" ")[0]}", style: const TextStyle(color: Colors.white70)),
            const Divider(color: Colors.white38),
            Text("👨‍🌾 ${stock["fullName"]}", style: const TextStyle(color: Colors.white)),
            Text("📞 ${stock["mobileNumber"]}", style: const TextStyle(color: Colors.white70)),
            Text("🏠 ${stock["address"]}", style: const TextStyle(color: Colors.white70)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "edit") {
              editStock(stock);
            } else if (value == "delete") {
              deleteStock(stock["_id"]);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: "edit", child: Text("✏️ Edit")),
            const PopupMenuItem(value: "delete", child: Text("🗑️ Delete")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/background_2.png", fit: BoxFit.cover),
          ),
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 4, 28, 6), Color.fromARGB(255, 36, 88, 38)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Manage Farmer Stocks",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    DropdownButtonFormField(
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person, color: Colors.green),
                        hintText: "Select Farmer",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
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
                        fetchStocks(selectedFarmer!["_id"]);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
                      : stocks.isEmpty
                          ? Center(
                              child: Text(
                                selectedFarmer == null ? "👆 Please select a farmer" : "📭 No stocks found",
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              itemCount: stocks.length,
                              itemBuilder: (context, index) {
                                return buildStockCard(stocks[index]);
                              },
                            ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, "/addHarvest");
          if (selectedFarmer != null) fetchStocks(selectedFarmer!["_id"]);
        },
        backgroundColor: Colors.yellow.shade700,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("Add Harvest",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
