import 'package:farmeragriapp/screens/views/buyer/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart'
    as custom_clippers;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const BuyerHome(),
      const OrderScreen(),
      Center(child: Text("Profile", style: GoogleFonts.poppins(fontSize: 22))),
    ];
    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(18, 40, 18, 0.8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(66, 118, 117, 117),
                blurRadius: 9,
                spreadRadius: 3),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: GNav(
          backgroundColor: Colors.transparent,
          color: Colors.yellow,
          activeColor: Colors.white,
          tabBackgroundColor: Colors.white24,
          gap: 10,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          iconSize: 30,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(icon: Icons.home, text: "Home"),
            GButton(icon: Icons.shopping_bag, text: "Orders"),
          
          ],
        ),
      ),
    );
  }
}

// --- Convert BuyerHome to StatefulWidget to fetch userId ---
class BuyerHome extends StatefulWidget {
  const BuyerHome({super.key});
  @override
  State<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
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

    const String userName = " Buyer";

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background2.jpg",
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
                        Color.fromRGBO(159, 157, 40, 1),
                        Color.fromRGBO(87, 164, 91, 0.7),
                        Color.fromARGB(255, 135, 168, 37),
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
              SizedBox(
                height: 300,
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  childAspectRatio: 1.15,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _modernGridButton(
                      context,
                      "Browse Products",
                      Icons.shopping_cart,
                      "/products",
                      gridFontSize,
                    ),
                    _modernGridButton(
                      context,
                      "Notifications",
                      Icons.notifications,
                      "/buyer_notifications",
                      gridFontSize,
                    ),
                    _modernGridButton(
                      context,
                      "Profile",
                      Icons.account_circle,
                      "/buyer_profile",
                      gridFontSize,
                      arguments: {'userId': userId ?? '', 'userType': 'Buyer'},
                    ),
                    _modernGridButton(
                      context,
                      "Support",
                      Icons.support_agent,
                      "/buyer_support",
                      gridFontSize,
                    ),
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
              Color.fromRGBO(53, 169, 51, 0.082),
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
                  color: const Color.fromARGB(255, 237, 248, 25)),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: fontSize + 2,
                color: const Color.fromARGB(239, 9, 9, 9),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserRepository {
  final FlutterSecureStorage storage;

  UserRepository(this.storage);

  Future<void> saveUserId(String userId) async {
    await storage.write(key: "userId", value: userId);
  }

  Future<String?> getUserId() async {
    return await storage.read(key: "userId");
  }

  // Add more methods for user-related operations as needed
}
