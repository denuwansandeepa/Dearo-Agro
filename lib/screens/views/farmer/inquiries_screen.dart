import 'package:farmeragriapp/screens/views/farmer/responses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

void main() => runApp(const InqueriesScreen());

class InquiriesApp extends StatelessWidget {
  const InquiriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: InqueriesScreen());
  }
}

class InqueriesScreen extends StatefulWidget {
  const InqueriesScreen({super.key});

  @override
  State<InqueriesScreen> createState() => _InqueriesScreenState();
}

class _InqueriesScreenState extends State<InqueriesScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    
    const FarmerHome(),
    const ResponsScreen(),
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(87, 164, 91, 0.8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 9, spreadRadius: 3),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: GNav(
          backgroundColor: Colors.transparent,
          color: Colors.white,
          activeColor: Colors.black,
          tabBackgroundColor: Colors.white.withOpacity(0.2),
          gap: 10,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          iconSize: 26,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(icon: Icons.help, text: "Inquiry",),
            GButton(icon: Icons.notifications, text: "Responses"),
           
            
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ClipPath(
              clipper: ArcClipper(),
              child: Container(
                height: 190,
                color: const Color.fromRGBO(87, 164, 91, 0.8),
                child: Center(
                  child: Column(
                    children: [
                       Stack(
              children: [
                ClipPath(
                  clipper: ArcClipper(),
                  child: Container(
                    height: 190,
                    color: const Color.fromRGBO(87, 164, 91, 0.8),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 50,
                  child: Text("Get Support",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color:Colors.black
                  ),)
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: Image.asset(
                    "assets/icons/support.png",
                    width: 30,
                    height: 30,
                  ),
                ),
              ],
            ),
                    
                     
                    ],
                  ),
                ),
              ),
            ),

             SizedBox(
              height: 30,
              child: Text(
                "Select inquiry Type",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                ),
              ),
            ),
            SizedBox(
              height: 500,
              child: GridView.count(
                primary: false,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                crossAxisCount: 2,
                children: <Widget>[
                  _buildGridButton(context, "General Inquiry",
                      Icons.agriculture, "/general"),
                 
                  _buildGridButton(context, "Expert Advice Inquiry",
                      Icons.attach_money, "/commiunity"),
                 
                  _buildGridButton(
                    
                      context, "Financial Support Inquiry", Icons.book, "/finacial"),
                  _buildGridButton(
                      context, "Technical Support Inquiry ", Icons.forum, "/technical"),
                ],
              ),
            ),
            const SizedBox(height: 20),
           
           
          ],
        ),
      ),
    );
  }

  Widget _buildGridButton(
      BuildContext context, String title, IconData icon, String route) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.normal,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
