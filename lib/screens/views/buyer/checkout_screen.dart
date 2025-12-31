import 'package:farmeragriapp/api/order_api.dart';
import 'package:farmeragriapp/models/order.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutScreen extends StatefulWidget {
  final Function(String shippingAddress, String paymentMethod) onCheckout;
  final String authToken;

  const CheckoutScreen(
      {super.key, required this.onCheckout, required this.authToken});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _shippingAddressController = TextEditingController();
  String _selectedPaymentMethod = 'COD';
  final OrderService _orderService =
      OrderService('https://dearoagro-backend.onrender.com/api');

  void _showPopup(String title, String message,
      {Color backgroundColor = Colors.white, Color textColor = Colors.black87}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: textColor)),
        content: Text(message, style: GoogleFonts.poppins(color: textColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins(color: textColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Checkout', style: GoogleFonts.poppins(fontSize: 20)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shipping Address
              Text(
                'Shipping Address',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _shippingAddressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(87, 164, 91, 0.8),
                      width: 2,
                    ),
                  ),
                  hintText: 'Enter your shipping address',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 24),
              // Payment Method
              Text(
                'Payment Method',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: DropdownButton<String>(
                  value: _selectedPaymentMethod,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ['COD', 'Credit Card', 'PayPal']
                      .map((method) => DropdownMenuItem(
                            value: method,
                            child: Text(
                              method,
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                      // Show popup if Credit Card or PayPal is selected
                      if (_selectedPaymentMethod != 'COD') {
                        _showPopup(
                          'Info',
                          'For Credit Card or online payments, please contact the company.\nCall us on 074 390 8274',
                          backgroundColor: Colors.yellow[800]!,
                          textColor: Colors.black,
                        );
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 21, 50, 22),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final shippingAddress =
                        _shippingAddressController.text.trim();
                    if (shippingAddress.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a shipping address')),
                      );
                      return;
                    }

                    final order = Order(
                      shippingAddress: shippingAddress,
                      paymentMethod: _selectedPaymentMethod,
                    );

                    try {
                      await _orderService.createOrder(
                          order.toJson(), widget.authToken);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Order placed successfully')),
                      );
                      widget.onCheckout(shippingAddress, _selectedPaymentMethod);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to place order: $e')),
                      );
                    }
                  },
                  child: Text(
                    'Place Order',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
