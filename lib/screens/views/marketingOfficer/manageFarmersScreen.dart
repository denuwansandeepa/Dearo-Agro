import 'package:farmeragriapp/api/farmer_api.dart';
import 'package:farmeragriapp/models/farmer_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageFarmersScreen extends StatefulWidget {
  const ManageFarmersScreen({super.key});

  @override
  State<ManageFarmersScreen> createState() => _ManageFarmersScreenState();
}

class _ManageFarmersScreenState extends State<ManageFarmersScreen> {
  List<Farmer> farmers = [];
  List<Farmer> filteredFarmers = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFarmers();
  }

  Future<void> fetchFarmers() async {
    try {
      setState(() {
        isLoading = true;
      });
      final fetchedFarmers = await FarmerApi.fetchFarmers();
      setState(() {
        farmers = fetchedFarmers;
        filteredFarmers = fetchedFarmers;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching farmers: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterFarmers(String query) {
    setState(() {
      filteredFarmers = farmers
          .where((farmer) =>
              farmer.mobileNumber.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteFarmer(String id) async {
    try {
      await FarmerApi.deleteFarmer(id);
      setState(() {
        farmers.removeWhere((farmer) => farmer.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer deleted successfully')),
      );
    } catch (error) {
      print('Error deleting farmer: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete farmer')),
      );
    }
  }

  Future<void> showDeleteFarmerDialog(
      BuildContext context, String farmerId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Farmer?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this farmer?',
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey[700])),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes',
                  style: GoogleFonts.poppins(color: Colors.redAccent)),
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteFarmer(farmerId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background4.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              ClipPath(
                clipper: ArcClipper(),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(119, 153, 161, 1),
                        Color.fromRGBO(2, 75, 5, 0.69),
                        Color.fromRGBO(119, 153, 161, 1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Manage Farmers",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Fixed Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: searchController,
                  onChanged: filterFarmers,
                  decoration: InputDecoration(
                    hintText: "Search by mobile number",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredFarmers.isEmpty
                              ? Center(
                                  child: Text(
                                    "No farmers found.",
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredFarmers.length,
                                  itemBuilder: (context, index) {
                                    final farmer = filteredFarmers[index];
                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color.fromARGB(
                                                    255, 30, 32, 30)
                                                .withOpacity(0.8),
                                            const Color.fromARGB(
                                                    255, 136, 211, 151)
                                                .withOpacity(0.8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(16),
                                            title: Text(
                                              farmer.fullName,
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 6.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Mobile: ${farmer.mobileNumber}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Branch: ${farmer.branchName ?? 'Not Assigned'}", // Display branchName
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            trailing: PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_vert,
                                                  color: Colors.black),
                                              onSelected: (value) async {
                                                if (value == 'edit') {
                                                  final result =
                                                      await Navigator.pushNamed(
                                                    context,
                                                    "/updateFarmer",
                                                    arguments: farmer,
                                                  );
                                                  if (result == true) {
                                                    fetchFarmers();
                                                  }
                                                } else if (value == 'delete') {
                                                  showDeleteFarmerDialog(
                                                      context, farmer.id);
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.edit,
                                                          color: Colors.yellow),
                                                      SizedBox(width: 8),
                                                      Text('Edit'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete,
                                                          color:
                                                              Colors.redAccent),
                                                      SizedBox(width: 8),
                                                      Text('Delete'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    "/createFarmer",
                  );
                  if (result == true) {
                    fetchFarmers();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  minimumSize: const Size(150, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.person_add, color: Colors.black),
                label: Text(
                  "Farmer",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
