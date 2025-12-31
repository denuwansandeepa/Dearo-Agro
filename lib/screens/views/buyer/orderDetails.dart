import 'package:farmeragriapp/api/order_api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  final String authToken;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.authToken,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final _orderService =
      OrderService('https://dearoagro-backend.onrender.com/api');
  Map<String, dynamic>? order;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    try {
      final data = await _orderService.fetchOrderDetails(
          widget.orderId, widget.authToken);
      setState(() {
        order = data;
        isLoading = false;
      });
    } catch (e) {
      _showSnack('Failed to load order details: $e');
      setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/background.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              // Scrollable content
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : order == null
                      ? const Center(child: Text('Order details not found'))
                      : SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minHeight: constraints.maxHeight),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipPath(
                                  clipper: ArcClipper(),
                                  child: Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF1C5126)
                                              .withOpacity(0.8),
                                          const Color(0xFF080B04)
                                              .withOpacity(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Order Details',
                                        style: GoogleFonts.poppins(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellow,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: Colors.white.withOpacity(0.9),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailColored(
                                              'Order ID', order!['_id'], const Color.fromARGB(255, 181, 168, 55)),
                                          _buildDetail('💰 Total',
                                              'Rs.${order!['totalAmount']}'),
                                          _buildDetail('🏠 Shipping Address',
                                              order!['shippingAddress']),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Items:',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Items inside separate cards
                                          ...List.generate(
                                              order!['items']?.length ?? 0, (i) {
                                            final item = order!['items'][i];
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(bottom: 8.0),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                color: const Color.fromARGB(255, 212, 231, 39).withOpacity(0.1),
                                                child: ListTile(
                                                  leading:
                                                      const Icon(Icons.shopping_bag),
                                                  title: Text(item['name']),
                                                  subtitle: Text(
                                                      'Quantity: ${item['quantity']} kg'),
                                                  trailing: Text(
                                                      'Rs.${item['price']}/kg'),
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: $value',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailColored(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: $value',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
