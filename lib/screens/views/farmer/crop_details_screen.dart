import 'package:dio/dio.dart';
import 'package:farmeragriapp/screens/forms/farmer/newUpdateForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class CropDetailsScreen extends StatefulWidget {
  const CropDetailsScreen({super.key});

  @override
  State<CropDetailsScreen> createState() => _CropDetailsScreenState();
}

class _CropDetailsScreenState extends State<CropDetailsScreen> {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  List<dynamic> _cropUpdates = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCropUpdates();
  }

  Future<void> _fetchCropUpdates() async {
    try {
      final userId = await _storage.read(key: "userId");
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "User not logged in";
        });
        return;
      }

      final response = await _dio
          .get("https://dearoagro-backend.onrender.com/api/cropfetch/$userId");

      if (response.statusCode == 200) {
        setState(() {
          _cropUpdates = response.data is List ? response.data : [];
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
        const SnackBar(content: Text("Failed to fetch crop updates")),
      );
    }
  }

  Future<void> _deleteCropUpdate(String id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _dio
          .delete("https://dearoagro-backend.onrender.com/api/cropdelete/$id");

      if (response.statusCode == 200) {
        setState(() {
          _cropUpdates.removeWhere((update) => update['_id'] == id);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data["message"])),
        );

        // Optional: Refresh from server to confirm
        await _fetchCropUpdates();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Find the first update with description key for transplanting
    final firstPlanting = _cropUpdates.firstWhere(
      (u) => u['description'] == "Transplanting",
      orElse: () => null,
    );
    final plantingDays = firstPlanting != null
        ? _daysSinceAddDate(firstPlanting['addDate'])
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewUpdateForm()),
          );
          if (result == true) {
            _fetchCropUpdates();
          }
        },
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
                    'Crop Updates',
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
          // Show days count at the top if available
          if (plantingDays != null)
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                'Days since planting: $plantingDays',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.yellow[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cropUpdates.isEmpty
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
                            Image.asset(
                              "assets/images/image5.png",
                              height: 250,
                              width: 250,
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            ..._cropUpdates.map((update) {
                              final descriptionKey =
                                  update['description'] ?? '';
                              final addDate = update['addDate'] ?? '';
                              final id = update['_id'];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCropUpdateCard(
                                      addDate, descriptionKey, id, update),
                                ],
                              );
                            }),
                            const SizedBox(height: 20),
                            Image.asset(
                              "assets/images/image5.png",
                              height: 250,
                              width: 250,
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropUpdateCard(
      String date, String descriptionKey, String id, Map update) {
    final days = _daysSinceAddDate(date);

    // Helper to get display text (simplified without translations)
    String getDisplayText(String value) {
      // Return the value as-is since we're removing translations
      return value;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: Color.fromRGBO(87, 164, 91, 0.8),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              descriptionKey,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            // Show fertilizer fields if available
            if (update['fertilizerType'] != null &&
                update['fertilizerType'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  'Fertilizer Type: ${getDisplayText(update['fertilizerType'].toString())}',
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                ),
              ),
            if (update['fertilizerAmount'] != null &&
                update['fertilizerUnit'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Fertilizer Amount: ${update['fertilizerAmount'].toString()} ${update['fertilizerUnit'].toString()}',
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                ),
              ),
            const SizedBox(height: 10),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _showDeleteConfirmationDialog(id),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 15),
                IconButton(
                  onPressed: () => _navigateToEditScreen(id),
                  icon: const Icon(
                    Icons.edit,
                    color: Color.fromRGBO(87, 164, 91, 0.8),
                    size: 20,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )),
        content: Text('Are you sure you want to delete this item?',
            style: GoogleFonts.poppins(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                  color: const Color.fromRGBO(87, 164, 91, 0.8),
                )),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCropUpdate(id);
            },
            child:
                Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEditScreen(String id) async {
    final updateToEdit =
        _cropUpdates.firstWhere((update) => update['_id'] == id);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewUpdateForm(existingData: updateToEdit),
      ),
    );
    if (result == true) {
      _fetchCropUpdates();
    }
  }

  int _daysSinceAddDate(String? addDate) {
    if (addDate == null || addDate.isEmpty) return 0;
    try {
      final start = DateTime.parse(addDate);
      final now = DateTime.now();
      return now.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }
}
