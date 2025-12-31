import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart'
    as custom_clippers;

class OfficerHome extends StatefulWidget {
  const OfficerHome({super.key});

  @override
  State<OfficerHome> createState() => _OfficerHomeState();
}

class _OfficerHomeState extends State<OfficerHome> {
  String? userId;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final id = await storage.read(key: "userId");
    setState(() {
      userId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double arcHeight = 250.0;
    const double gridFontSize = 12.0;

    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = "Good Morning";
    } else if (hour < 18) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Night";
    }

    const String userName = " Officer";

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: Stack(
        children: [
          // Full-screen background image
        Positioned.fill(
          child: Image.asset(
            "assets/images/background_1.png",
            fit: BoxFit.cover,
          ),
        ),
          Column(
            children: <Widget>[
              ClipPath(
                clipper: custom_clippers.ArcClipper(),
                child: Container(
                  height: arcHeight,
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
                    child: Column(
                      children: [
                        const SizedBox(height: 25),
                        const SizedBox(height: 10),
                        Text(
                          "Hi$userName,",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          greeting,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.normal,
                            fontSize: 17,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 300,
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  childAspectRatio: 1.15,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _modernGridButton(
                      context,
                      "Manage Farmers",
                      Icons.group,
                      "/manageFarmers",
                      gridFontSize,
                    ),
                     _modernGridButton(
                      context,
                      "Add Harvest",
                      Icons.add,
                      "/addHarvest",
                      gridFontSize,
                    ),
                     _modernGridButton(
                      context,
                      "Harvest Details",
                      Icons.manage_history_sharp,
                      "/getHarvest",
                      gridFontSize,
                    ),
                    _modernGridButton(
                      context,
                      "Profile",
                      Icons.account_circle,
                      "/officerProfile",
                      gridFontSize,
                      arguments: {
                        'userId': userId ?? '',
                        'userType': 'Officer'
                      },
                    )
                   
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modernGridButton(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    double fontSize, {
    Map<String, dynamic>? arguments,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.pushNamed(context, route, arguments: arguments);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          gradient: const LinearGradient(
            colors: [
              Colors.white,
              Color.fromRGBO(6, 43, 80, 0.078),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 1, 41, 63).withOpacity(0.09),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon,
                  size: fontSize + 18,
                  color: Colors.yellow),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: fontSize + 2,
                color:Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
