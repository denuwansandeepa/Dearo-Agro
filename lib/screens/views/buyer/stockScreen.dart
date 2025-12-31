import 'dart:convert';
import 'package:farmeragriapp/api/cart_api.dart';
import 'package:farmeragriapp/api/crop_api.dart';
import 'package:farmeragriapp/api/stock_api.dart';
import 'package:farmeragriapp/models/crop.dart';
import 'package:farmeragriapp/models/stock_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cartScreen.dart';

class OurProductsScreen extends StatefulWidget {
  const OurProductsScreen({super.key});

  @override
  _OurProductsScreenState createState() => _OurProductsScreenState();
}

class _OurProductsScreenState extends State<OurProductsScreen> {
  late Future<Map<String, dynamic>> _futureData;
  final Map<String, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final stocks = await StockApi.fetchListedProducts();
    final crops = await CropApi.fetchCrops();
    return {"stocks": stocks, "crops": crops};
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget cropImage(String imageData) {
    if (imageData.startsWith('data:image')) {
      try {
        final base64Str = imageData.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
        );
      } catch (_) {
        return const Icon(Icons.broken_image, size: 50);
      }
    } else {
      return Image.network(
        imageData.isNotEmpty ? imageData : "https://via.placeholder.com/150",
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Our Products", style: GoogleFonts.poppins()),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Cartscreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No products available"));
          }

          final stocks = snapshot.data!["stocks"] as List<Stock>;
          final crops = snapshot.data!["crops"] as List<Crop>;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              _quantityControllers.putIfAbsent(
                  stock.id, () => TextEditingController());

              final crop = crops.firstWhere(
                (c) => c.name.toLowerCase() == stock.cropName.toLowerCase(),
                orElse: () => Crop(
                    id: "", name: stock.cropName, imageUrl: "", category: ''),
              );

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      cropImage(crop.imageUrl),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(stock.cropName,
                                style: GoogleFonts.poppins(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              "Available: ${stock.currentAmount} kg",
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _quantityControllers[stock.id],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                      labelText: "Quantity (kg)",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final controller =
                                        _quantityControllers[stock.id];
                                    final quantityText =
                                        controller?.text.trim() ?? '';
                                    final quantity =
                                        double.tryParse(quantityText) ?? 0;

                                    if (quantity < 0.1) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Minimum quantity is 0.1 kg")),
                                      );
                                      return;
                                    }

                                    final success = await CartApi.addToCart(
                                        stock.id, quantity);

                                    if (success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "${stock.cropName} added to cart ($quantity kg)")),
                                      );
                                      controller?.clear();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text("Failed to add to cart")),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Add"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
