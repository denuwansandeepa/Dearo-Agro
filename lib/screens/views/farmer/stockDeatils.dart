// import 'package:flutter/material.dart';
// import 'package:farmeragriapp/models/stock_model.dart';
// import 'package:farmeragriapp/api/stock_api.dart';

// class StockDetailScreen extends StatefulWidget {
//   final Stock stock;

//   const StockDetailScreen({Key? key, required this.stock}) : super(key: key);

//   @override
//   State<StockDetailScreen> createState() => _StockDetailScreenState();
// }

// class _StockDetailScreenState extends State<StockDetailScreen> {
//   late Stock currentStock;

//   @override
//   void initState() {
//     super.initState();
//     currentStock = widget.stock;
//   }

//   Future<void> _deleteStock() async {
//     try {
//       await StockApi.deleteStock(currentStock.id!);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Stock deleted successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//       Navigator.pop(context, true); // Return true to indicate deletion
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error deleting stock: $error'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   void _showDeleteConfirmation() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Stock'),
//           content: Text('Are you sure you want to delete ${currentStock.cropName} stock?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _deleteStock();
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
//         title: Text(currentStock.cropName),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               if (value == 'edit') {
//                 _navigateToEdit();
//               } else if (value == 'delete') {
//                 _showDeleteConfirmation();
//               }
//             },
//             itemBuilder: (BuildContext context) => [
//               // const PopupMenuItem(
//               //   value: 'edit',
//               //   child: Row(
//               //     children: [
//               //       Icon(Icons.edit, color: Colors.blue),
//               //       SizedBox(width: 8),
//               //       Text('Edit'),
//               //     ],
//               //   ),
//               // ),
//               // const PopupMenuItem(
//               //   value: 'delete',
//               //   child: Row(
//               //     children: [
//               //       Icon(Icons.delete, color: Colors.red),
//               //       SizedBox(width: 8),
//               //       Text('Delete'),
//               //     ],
//               //   ),
//               // ),
//             ],
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Crop Information Card
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.green.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Icon(
//                             Icons.grass,
//                             color: Colors.green,
//                             size: 30,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 currentStock.cropName,
//                                 style: const TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Harvest Date: ${_formatDate(currentStock.harvestDate)}',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Farmer Information Card
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Farmer Information',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     _buildInfoRow(Icons.person, 'Full Name', currentStock.fullName),
//                     const SizedBox(height: 12),
//                     _buildInfoRow(Icons.phone, 'Mobile Number', currentStock.mobileNumber),
//                     const SizedBox(height: 12),
//                     _buildInfoRow(Icons.location_on, 'Address', currentStock.address),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Stock Details Card
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Stock Details',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildStockDetailItem(
//                             'Total Amount',
//                             '${currentStock.totalAmount} kg',
//                             Icons.scale,
//                             Colors.blue,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: _buildStockDetailItem(
//                             'Price per Kg',
//                             '₹${currentStock.pricePerKg}',
//                             Icons.currency_rupee,
//                             Colors.orange,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     _buildStockDetailItem(
//                       'Total Value',
//                       '₹${currentStock.totalValue.toStringAsFixed(2)}',
//                       Icons.account_balance_wallet,
//                       Colors.green,
//                       isLarge: true,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Additional Information Card
//             if (currentStock.createdAt != null)
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Additional Information',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       _buildInfoRow(
//                         Icons.calendar_today,
//                         'Added On',
//                         _formatDate(currentStock.createdAt!),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 24),

//             // Action Buttons
//             // Row(
//             //   children: [
//             //     Expanded(
//             //       child: ElevatedButton.icon(
//             //         onPressed: _navigateToEdit,
//             //         icon: const Icon(Icons.edit),
//             //         label: const Text('Edit Stock'),
//             //         style: ElevatedButton.styleFrom(
//             //           backgroundColor: Colors.blue,
//             //           foregroundColor: Colors.white,
//             //           padding: const EdgeInsets.all(16),
//             //           shape: RoundedRectangleBorder(
//             //             borderRadius: BorderRadius.circular(8),
//             //           ),
//             //         ),
//             //       ),
//             //     ),
//             //     const SizedBox(width: 16),
//             //     Expanded(
//             //       child: ElevatedButton.icon(
//             //         onPressed: _showDeleteConfirmation,
//             //         icon: const Icon(Icons.delete),
//             //         label: const Text('Delete Stock'),
//             //         style: ElevatedButton.styleFrom(
//             //           backgroundColor: Colors.red,
//             //           foregroundColor: Colors.white,
//             //           padding: const EdgeInsets.all(16),
//             //           shape: RoundedRectangleBorder(
//             //             borderRadius: BorderRadius.circular(8),
//             //           ),
//             //         ),
//             //       ),
//             //     ),
//             //   ],
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(icon, size: 20, color: Colors.grey[600]),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStockDetailItem(
//     String label,
//     String value,
//     IconData icon,
//     Color color, {
//     bool isLarge = false,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: isLarge ? 32 : 24),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: isLarge ? 20 : 16,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   void _navigateToEdit() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddStockScreen(
//           userId: currentStock.memberId,
//           stockToEdit: currentStock,
//         ),
//       ),
//     );

//     if (result == true) {
//       // Stock was updated, pop back to refresh the list
//       Navigator.pop(context, true);
//     }
//   }
// }