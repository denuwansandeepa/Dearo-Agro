import 'package:farmeragriapp/screens/views/farmer/cropCalender.dart';
import 'package:farmeragriapp/screens/views/farmer/notifications.dart';
import 'package:farmeragriapp/screens/views/farmer/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart'
    as custom_clippers;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

void main() {
  runApp(const FarmerDashboardApp());
}

class FarmerDashboardApp extends StatelessWidget {
  const FarmerDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Placeholder(),
    );
  }
}

class FarmerDashboard extends StatefulWidget {
  final String userId;

  const FarmerDashboard({super.key, required this.userId});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const FarmerHome(),
      const SoilTestScreen(),
      const CropCalenderScreen(),
      ProfileScreen(
        userId: widget.userId,
        userType: "Farmer",
      ),
    ];
    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(1, 45, 9, 0.8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(66, 6, 131, 1),
                blurRadius: 9,
                spreadRadius: 3),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: GNav(
          backgroundColor: Colors.transparent,
          color: Colors.yellow,
          activeColor: Colors.white,
          tabBackgroundColor: Colors.white.withOpacity(0.2),
          gap: 4,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          iconSize: 30,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(icon: Icons.home, text: "Home"),
            GButton(icon: Icons.notifications, text: "Test"),
            GButton(icon: Icons.calendar_month, text: "Calendar"),
            GButton(icon: Icons.account_circle, text: "Profile"),
          ],
        ),
      ),
    );
  }
}

class FarmerHome extends StatelessWidget {
  const FarmerHome({super.key});
  @override
  Widget build(BuildContext context) {
    const double arcHeight = 250.0;
    const int gridCrossAxisCount = 3;
    const double gridChildAspectRatio = 0.6;
    const double gridHeight = 400.0;
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

    String userName = "User";

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // Main content
          Column(
            children: <Widget>[
              ClipPath(
                clipper: custom_clippers.ArcClipper(),
                child: Container(
                  height: arcHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(40, 159, 46, 1),
                        Color.fromRGBO(87, 164, 91, 0.7),
                        Color.fromARGB(255, 31, 150, 31),
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
                          "Hi $userName,",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          greeting,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Modern grid with glass effect
              SizedBox(
                height: gridHeight,
                child: GridView.count(
                  primary: false,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: gridCrossAxisCount,
                  childAspectRatio: gridChildAspectRatio,
                  children: <Widget>[
                    _modernGridButton(context, 'Cultivational Details',
                        Icons.agriculture, "/cultivational", gridFontSize),
                    _modernGridButton(context, 'Crop Updates', Icons.eco,
                        "/crop_updates", gridFontSize),
                    _modernGridButton(context, 'Cultivational Expenses',
                        Icons.attach_money, "/expenses", gridFontSize),
                    _modernGridButton(context, 'Stock Details',
                        Icons.store_mall_directory, "/stock", gridFontSize),
                    // _modernGridButton(context, 'Inquiries', Icons.forum,
                    //     "/technical", gridFontSize),
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

  Widget _modernGridButton(BuildContext context, String title, IconData icon,
      String route, double fontSize) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(82, 99, 82, 0.125),
              Color.fromRGBO(117, 156, 119, 0.086),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 26, 48, 26).withOpacity(0.09),
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
                    color: Colors.green.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon,
                  size: fontSize + 18,
                  color: const Color.fromARGB(255, 238, 246, 1)),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: fontSize + 2,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
