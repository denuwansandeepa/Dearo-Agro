// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:farmeragriapp/api/stock_api.dart';
// import 'package:farmeragriapp/api/cart_api.dart';
// import 'package:farmeragriapp/models/stock_model.dart';
// import 'package:farmeragriapp/screens/views/buyer/cartScreen.dart';

// class BrowseProductsScreen extends StatefulWidget {
//   const BrowseProductsScreen({Key? key}) : super(key: key);

//   @override
//   State<BrowseProductsScreen> createState() => _BrowseProductsScreenState();
// }

// class _BrowseProductsScreenState extends State<BrowseProductsScreen> {
//   final List<String> categories = [
//     'All',
//     'Vegetables',
//     'Fruits',
//     'Seeds',
//     'Grains'
//   ];
//   String selectedCategory = 'All';
//   List<Stock> stocks = [];
//   bool isLoading = true;
//   final Map<String, double> selectedQuantities = {};
//   final storage = FlutterSecureStorage();

//   @override
//   void initState() {
//     super.initState();
//     fetchListedProducts();
//   }

//   Future<void> fetchListedProducts() async {
//     setState(() => isLoading = true);
//     try {
//       final fetchedStocks = await StockApi.fetchListedProducts();
//       setState(() => stocks = fetchedStocks);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading products: ${e.toString()}')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> addStockToCart(Stock stock) async {
//     double quantity = selectedQuantities[stock.id!] ?? 1.0;
//     if (quantity <= 0) return;

//     try {
//       final token = await storage.read(key: "authToken");
//       if (token == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please sign in to add to cart')),
//         );
//         return;
//       }

//       // Use stock ID as product ID for cart
//       final success = await CartApi.addToCart(token, stock.id!, quantity);
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 'Added ${quantity.toStringAsFixed(1)} kg of ${stock.cropName}'),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error adding to cart: ${e.toString()}')),
//       );
//     }
//   }

//   Widget _buildStockImage() {
//     // Since stocks don't have images, use a placeholder with crop icon
//     return Container(
//       width: 60,
//       height: 60,
//       decoration: BoxDecoration(
//         color: Colors.green[100],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Icon(
//         Icons.eco,
//         size: 30,
//         color: Colors.green[600],
//       ),
//     );
//   }

//   Widget _buildQuantityInput(Stock stock) {
//     final controller = TextEditingController(
//       text: (selectedQuantities[stock.id!] ?? 1.0).toStringAsFixed(1),
//     );

//     final availableStock = stock.currentAmount;

//     return SizedBox(
//       height: 36,
//       child: TextField(
//         controller: controller,
//         keyboardType: const TextInputType.numberWithOptions(decimal: true),
//         textAlign: TextAlign.center,
//         decoration: InputDecoration(
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey[300]!),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey[300]!),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.green.shade400),
//           ),
//           suffixText: 'kg',
//           suffixStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
//           isDense: true,
//         ),
//         style: GoogleFonts.poppins(fontSize: 12),
//         onChanged: (value) {
//           double? newQuantity = double.tryParse(value);
//           if (newQuantity != null && newQuantity > 0) {
//             if (newQuantity > availableStock) {
//               controller.text = availableStock.toStringAsFixed(1);
//               selectedQuantities[stock.id!] = availableStock;
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                       'Max available: ${availableStock.toStringAsFixed(1)} kg'),
//                   duration: const Duration(seconds: 2),
//                 ),
//               );
//             } else {
//               selectedQuantities[stock.id!] = newQuantity;
//             }
//           }
//         },
//       ),
//     );
//   }

//   // Helper method to determine category based on crop name
//   String getCropCategory(String cropName) {
//     final name = cropName.toLowerCase();
//     if (name.contains('tomato') ||
//         name.contains('carrot') ||
//         name.contains('cabbage') ||
//         name.contains('potato') ||
//         name.contains('onion')) {
//       return 'Vegetables';
//     } else if (name.contains('apple') ||
//         name.contains('banana') ||
//         name.contains('mango') ||
//         name.contains('orange') ||
//         name.contains('grape')) {
//       return 'Fruits';
//     } else if (name.contains('rice') ||
//         name.contains('wheat') ||
//         name.contains('corn') ||
//         name.contains('barley')) {
//       return 'Grains';
//     } else if (name.contains('seed')) {
//       return 'Seeds';
//     }
//     return 'Vegetables'; // Default category
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredStocks = selectedCategory == 'All'
//         ? stocks
//         : stocks
//             .where((s) => getCropCategory(s.cropName) == selectedCategory)
//             .toList();

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: Colors.green[600],
//         title: Text('Browse Products',
//             style:
//                 GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.shopping_cart),
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const CartScreen()),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Category Chips
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             child: Row(
//               children: categories.map((category) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 6),
//                   child: ChoiceChip(
//                     label: Text(category,
//                         style: GoogleFonts.poppins(
//                             color: selectedCategory == category
//                                 ? Colors.white
//                                 : Colors.black)),
//                     selected: selectedCategory == category,
//                     selectedColor: Colors.green[600],
//                     backgroundColor: Colors.grey[200],
//                     onSelected: (_) =>
//                         setState(() => selectedCategory = category),
//                     labelPadding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//           // Product Grid
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : stocks.isEmpty
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.inventory_2,
//                                 size: 64, color: Colors.grey[400]),
//                             const SizedBox(height: 16),
//                             Text(
//                               'No products available',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 18,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : RefreshIndicator(
//                         onRefresh: fetchListedProducts,
//                         child: GridView.builder(
//                           padding: const EdgeInsets.all(16),
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 16,
//                             mainAxisSpacing: 16,
//                             childAspectRatio: 0.7,
//                           ),
//                           itemCount: filteredStocks.length,
//                           itemBuilder: (context, index) {
//                             final stock = filteredStocks[index];
//                             return Card(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16)),
//                               elevation: 4,
//                               shadowColor: Colors.grey.shade300,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     // Image placeholder
//                                     Expanded(
//                                       child: Center(
//                                         child: _buildStockImage(),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     // Crop Name
//                                     Text(
//                                       stock.cropName,
//                                       style: GoogleFonts.poppins(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 13),
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     const SizedBox(height: 2),
//                                     // Farmer name
//                                     Text(
//                                       'By ${stock.fullName}',
//                                       style: GoogleFonts.poppins(
//                                           color: Colors.grey[600],
//                                           fontSize: 10),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     const SizedBox(height: 4),
//                                     // Price
//                                     Text(
//                                       'Rs.${stock.pricePerKg.toStringAsFixed(2)}/kg',
//                                       style: GoogleFonts.poppins(
//                                           color: Colors.green[700],
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w600),
//                                     ),
//                                     const SizedBox(height: 2),
//                                     // Availability
//                                     Text(
//                                       'Available: ${stock.currentAmount.toStringAsFixed(1)} kg',
//                                       style: GoogleFonts.poppins(
//                                           color: stock.currentAmount > 0
//                                               ? Colors.grey[600]
//                                               : Colors.red,
//                                           fontSize: 10),
//                                     ),
//                                     const SizedBox(height: 6),
//                                     // Quantity input
//                                     _buildQuantityInput(stock),
//                                     const SizedBox(height: 6),
//                                     // Add to cart
//                                     SizedBox(
//                                       width: double.infinity,
//                                       height: 36,
//                                       child: ElevatedButton(
//                                         onPressed: stock.currentAmount > 0
//                                             ? () => addStockToCart(stock)
//                                             : null,
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.green[600],
//                                           shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(10)),
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 4),
//                                           textStyle: GoogleFonts.poppins(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w500),
//                                         ),
//                                         child: Text(
//                                           stock.currentAmount > 0
//                                               ? 'Add to Cart'
//                                               : 'Out of Stock',
//                                           style: GoogleFonts.poppins(
//                                             color: Colors.white,
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }
