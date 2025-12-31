import 'package:farmeragriapp/api/order_api.dart';
import 'package:farmeragriapp/screens/views/buyer/orderDetails.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 50)
      ..quadraticBezierTo(
          size.width / 2, size.height, size.width, size.height - 50)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final storage = const FlutterSecureStorage();
  final _orderService =
      OrderService('https://dearoagro-backend.onrender.com/api');

  List<dynamic> orders = [];
  bool isLoading = true;
  String filter = "all"; // all, pending, complete

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final token = await storage.read(key: "authToken");
    if (token == null) {
      _showSnack('Please sign in to view orders');
      setState(() => isLoading = false);
      return;
    }
    try {
      final data = await _orderService.fetchBuyerOrders(token);
      setState(() {
        orders = data['orders'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      _showSnack('Failed to fetch orders: $e');
      setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  List<dynamic> get filteredOrders {
    if (filter == "all") return orders;
    return orders.where((o) => (o['status'] ?? '').toLowerCase() == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (orders.isEmpty)
            _buildEmptyOrders()
          else
            Column(
              children: [
                _buildHeader(),
                _buildFilterButtons(),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ClipPath(
      clipper: ArcClipper(),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1C5126).withOpacity(0.8),
              const Color(0xFF080B04).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            'My Orders',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.yellow,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _filterButton("All", "all", Colors.green.shade600),
          const SizedBox(width: 8),
          _filterButton("Pending", "pending", Colors.orange),
          const SizedBox(width: 8),
          _filterButton("Complete", "complete", Colors.green),
        ],
      ),
    );
  }

  Widget _filterButton(String text, String value, Color activeColor) {
    bool isActive = filter == value;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? activeColor : Colors.grey.shade300,
        foregroundColor: isActive ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      ),
      onPressed: () {
        setState(() => filter = value);
      },
      child: Text(
        text,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Text(
        'No orders found',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    String status = (order['status'] ?? 'Unknown').toString();
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'complete':
        statusColor = Colors.greenAccent;
        break;
      case 'pending':
        statusColor = Colors.orangeAccent;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      color: Colors.black.withOpacity(0.6),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          'Order ID: ${order['_id']}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: Rs.${order['totalAmount']}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.circle, size: 10, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          final token = await storage.read(key: "authToken");
          if (token != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailsScreen(
                  orderId: order['_id'],
                  authToken: token,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
