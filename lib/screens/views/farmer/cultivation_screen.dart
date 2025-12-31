import 'package:dio/dio.dart';
import 'package:farmeragriapp/screens/forms/farmer/addCultivational.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class CultivationalScreen extends StatefulWidget {
  const CultivationalScreen({super.key});

  @override
  State<CultivationalScreen> createState() => _CultivationalScreenState();
}

class _CultivationalScreenState extends State<CultivationalScreen> {
  final storage = const FlutterSecureStorage();
  final Dio _dio = Dio();
  List<dynamic> _data = [];
  bool _isLoading = true;
  // ignore: unused_field
  String? _errorMessage;
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final userId = await storage.read(key: "userId");
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "User not logged in";
        });
        return;
      }

      final response = await _dio
          .get("https://dearoagro-backend.onrender.com/api/fetch/$userId");

      if (response.statusCode == 200) {
        setState(() {
          _data = response.data is List ? response.data : [];
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: ${e.toString()}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch data")),
      );
    }
  }

  Future<void> _deleteCultivation(String id) async {
    try {
      // Optimistically remove the item from local state
      final itemToRemove = _data.firstWhere((item) => item['_id'] == id);
      setState(() {
        _data.removeWhere((item) => item['_id'] == id);
      });

      final response = await _dio
          .delete("https://dearoagro-backend.onrender.com/api/delete/$id");

      if (response.statusCode != 200) {
        // If deletion fails on server, add the item back
        setState(() {
          _data.add(itemToRemove);
        });
        throw Exception("Server deletion failed");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.data["message"])),
      );

      // Optional: Refresh from server to confirm
      await _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete: ${e.toString()}")),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Not specified";
    try {
      return DateFormat('yyyy/MM/dd').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  /// Helper to calculate days between start date and now
  int _daysFromStart(String? startDateString) {
    if (startDateString == null || startDateString.isEmpty) return 0;
    try {
      final start = DateTime.parse(startDateString);
      final now = DateTime.now();
      return now.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    'Cultivation Details',
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
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _handleRefresh,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _data.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No data available',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Image.asset("assets/images/image3.png")
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              // Show only Number of Days (outside cards)
                              ..._data.map((cultivation) {
                                final startDateRaw =
                                    cultivation['startDate']?.toString();
                                final days = _daysFromStart(startDateRaw);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 2),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Days since start: $days",
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        color: Colors.yellow[700],
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                              ..._data.map((cultivation) {
                                final id = cultivation['_id'];
                                final memberId =
                                    cultivation['memberId']?.toString() ??
                                        'N/A';
                                final cropCategory =
                                    cultivation['cropCategory'] ??
                                        cultivation['category'] ??
                                        'N/A';
                                final cropName = cultivation['cropName'] ??
                                    cultivation['crop'] ??
                                    'N/A';
                                final district =
                                    cultivation['district'] ?? 'N/A';
                                final city = cultivation['city'] ?? 'N/A';
                                final startDate = _formatDate(
                                    cultivation['startDate']?.toString());
                                final nic = cultivation['nic'] ?? 'N/A';
                                final cropYieldSize =
                                    cultivation['cropYieldSize']?.toString() ??
                                        'N/A';

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 17, vertical: 10),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Color.fromRGBO(87, 164, 91, 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Member ID: $memberId",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: const Color.fromARGB(
                                                    221, 12, 28, 1),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "Category: $cropCategory",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Crop: $cropName",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Location: $district, $city",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Start Date: $startDate",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "NIC: $nic",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Crop Yield Size: $cropYieldSize acres",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Divider(
                                            height: 1, color: Colors.grey),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: Text(
                                                        'Confirm Delete',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                    content: Text(
                                                        'Are you sure you want to delete this item?',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .black)),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: Text('Cancel',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        87,
                                                                        164,
                                                                        91,
                                                                        0.8))),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          _deleteCultivation(
                                                              id);
                                                        },
                                                        child: Text('Delete',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: Colors
                                                                        .red)),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            IconButton(
                                              onPressed: () async {
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CultivationalAddScreen(
                                                      existingData: cultivation,
                                                    ),
                                                  ),
                                                );
                                                if (result == true) {
                                                  _fetchData();
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Color.fromRGBO(
                                                    87, 164, 91, 0.8),
                                                size: 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 10),
                              Image.asset("assets/images/image3.png",
                                  height: 200, width: 200)
                            ],
                          ),
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CultivationalAddScreen()),
          );
          if (result == true) _fetchData();
        },
        backgroundColor: const Color.fromRGBO(87, 164, 91, 0.8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
