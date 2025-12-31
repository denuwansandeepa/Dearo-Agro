import 'package:dio/dio.dart';
import 'package:farmeragriapp/screens/forms/farmer/add_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class CultivationalExpense extends StatefulWidget {
  const CultivationalExpense({super.key});

  @override
  State<CultivationalExpense> createState() => _CultivationalExpenseState();
}

class _CultivationalExpenseState extends State<CultivationalExpense> {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  List<dynamic> _cropExpenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    try {
      final userId = await _storage.read(key: "userId");
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await _dio
          .get("https://dearoagro-backend.onrender.com/api/efetch/$userId");

      if (response.statusCode == 200) {
        setState(() {
          _cropExpenses = response.data is List ? response.data : [];
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load expenses");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch crop expenses")),
      );
    }
  }

  Future<void> _deleteExpense(String id) async {
    if (!mounted) return; // Ensure the widget is still mounted

    try {
      final response = await _dio
          .delete("https://dearoagro-backend.onrender.com/api/edelete/$id");

      if (response.statusCode == 200) {
        setState(() {
          _cropExpenses.removeWhere((e) => e['_id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data["message"] ?? "Deleted")),
        );
      } else {
        throw Exception("Failed to delete");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  void _navigateToForm({Map<String, dynamic>? data}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpense(existingData: data),
      ),
    );
    if (result == true) {
      _fetchExpenses();
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this expense?",
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: GoogleFonts.poppins(
                    color: const Color.fromRGBO(87, 164, 91, 0.8))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteExpense(id);
            },
            child:
                Text("Delete", style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Map<String, dynamic> expense) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color.fromRGBO(87, 164, 91, 0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense['addDate'] ?? 'Date not available',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              expense['description'] ?? 'No Description',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Rs.${expense['expense'] ?? '0'}",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _confirmDelete(expense['_id']),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
                IconButton(
                  onPressed: () => _navigateToForm(data: expense),
                  icon: const Icon(Icons.edit,
                      color: Color.fromRGBO(87, 164, 91, 0.8)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: const Color.fromRGBO(87, 164, 91, 0.8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          ClipPath(
            clipper: ArcClipper(),
            child: Container(
              height: 190,
              color: const Color.fromRGBO(87, 164, 91, 0.8),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    "Cultivational Expenses",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cropExpenses.isEmpty
                    ? Center(
                        child: Text(
                          "No cultivation expenses recorded",
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _cropExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = _cropExpenses[index];
                          return _buildExpenseCard(expense);
                        },
                      ),
          ),
          const SizedBox(height: 10),
          Image.asset("assets/images/image2.png", height: 200, width: 200)
        ],
      ),
    );
  }
}
