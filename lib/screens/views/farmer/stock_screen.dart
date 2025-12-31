// import 'package:farmeragriapp/api/stock_api.dart';
// import 'package:farmeragriapp/models/stock_model.dart';
// import 'package:farmeragriapp/screens/views/farmer/stockDeatils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:google_fonts/google_fonts.dart';

// class StockListScreen extends StatefulWidget {
//   const StockListScreen({Key? key}) : super(key: key);

//   @override
//   State<StockListScreen> createState() => _StockListScreenState();
// }

// class _StockListScreenState extends State<StockListScreen> {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();
//   List<Stock> stocks = [];
//   bool isLoading = true;
//   String? currentUserId;

//   @override
//   void initState() {
//     super.initState();
//     _loadStocks();
//   }

//   Future<void> _loadStocks() async {
//     setState(() => isLoading = true);

//     try {
//       currentUserId = await _storage.read(key: "userId");

//       if (currentUserId != null) {
//         final fetchedStocks =
//             await StockApi.fetchStocksByUserId(currentUserId!);
//         setState(() {
//           stocks = fetchedStocks;
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//         _showErrorSnackBar('User not logged in');
//       }
//     } catch (error) {
//       setState(() => isLoading = false);
//       _showErrorSnackBar('Error loading stocks: $error');
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         action: SnackBarAction(
//           label: 'Retry',
//           onPressed: _loadStocks,
//         ),
//       ),
//     );
//   }

//   Future<void> _deleteStock(String stockId) async {
//     try {
//       await StockApi.deleteStock(stockId);
//       _loadStocks(); // Refresh the list
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Stock deleted successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error deleting stock: $error'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   void _showDeleteConfirmation(Stock stock) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Stock'),
//           content:
//               Text('Are you sure you want to delete ${stock.cropName} stock?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _deleteStock(stock.id!);
//               },
//               style: TextButton.styleFrom(foregroundColor: Colors.red),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'My Stocks',
//           style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : stocks.isEmpty
//               ? _buildEmptyState()
//               : RefreshIndicator(
//                   onRefresh: _loadStocks,
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: stocks.length,
//                     itemBuilder: (context, index) {
//                       final stock = stocks[index];
//                       return _buildStockCard(stock);
//                     },
//                   ),
//                 ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.inventory_2_outlined,
//             size: 80,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No stocks available',
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'No stocks to display at the moment',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStockCard(Stock stock) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => StockDetailScreen(stock: stock),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       stock.cropName,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ),
//                   PopupMenuButton<String>(
//                     onSelected: (value) {
//                       if (value == 'delete') {
//                         _showDeleteConfirmation(stock);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => [
//                       // const PopupMenuItem(
//                       //   value: 'delete',
//                       //   child: Row(
//                       //     children: [
//                       //       Icon(Icons.delete, color: Colors.red),
//                       //       SizedBox(width: 8),
//                       //       Text('Delete'),
//                       //     ],
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   const Icon(Icons.person, size: 16, color: Colors.grey),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       stock.fullName,
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   const Icon(Icons.location_on, size: 16, color: Colors.grey),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       stock.address,
//                       style: const TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _buildInfoChip('${stock.totalAmount} kg', Icons.scale),
//                   _buildInfoChip('Rs.${stock.pricePerKg}/kg', Icons.money),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   'Total Value: Rs.${_calculateTotalValue(stock)}',
//                   style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _calculateTotalValue(Stock stock) {
//     final totalValue = stock.totalAmount * stock.pricePerKg;
//     return totalValue.toStringAsFixed(2);
//   }

//   Widget _buildInfoChip(String label, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: Colors.grey[600]),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800]),
//           ),
//         ],
//       ),
//     );
//   }
// }
