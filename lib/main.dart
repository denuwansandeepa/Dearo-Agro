import 'package:farmeragriapp/screens/views/buyer/stockScreen.dart';
import 'package:farmeragriapp/screens/views/marketingOfficer/FarmerStockScreen.dart';
import 'package:farmeragriapp/screens/views/marketingOfficer/addHarvestDetails.dart';
import 'package:flutter/material.dart';

// Screens and Forms
import 'package:farmeragriapp/screens/forms/farmer/add_expense.dart';
import 'package:farmeragriapp/screens/forms/farmer/commiunityIScreen.dart';
import 'package:farmeragriapp/screens/forms/farmer/financialIScreen.dart';
import 'package:farmeragriapp/screens/forms/farmer/generalIScreen.dart';
import 'package:farmeragriapp/screens/forms/farmer/technicalIScreen.dart';
import 'package:farmeragriapp/screens/forms/farmer/technical_inq_crud.dart';
import 'package:farmeragriapp/screens/forms/farmer/update_farmer_screen.dart';
import 'package:farmeragriapp/screens/forms/marketingOfficer/createFarmer.dart';
import 'package:farmeragriapp/screens/views/farmer/Cultivational_expense.dart';
import 'package:farmeragriapp/screens/views/buyer/buyerDashboard.dart';
import 'package:farmeragriapp/screens/views/farmer/crop_details_screen.dart';
import 'package:farmeragriapp/screens/views/farmer/cultivation_screen.dart';
import 'package:farmeragriapp/screens/forms/farmer/addCultivational.dart';
import 'package:farmeragriapp/screens/views/farmer/inquiries_screen.dart';
import 'package:farmeragriapp/screens/forms/farmer/newUpdateForm.dart';
import 'package:farmeragriapp/screens/forms/signIn_screen.dart';
import 'package:farmeragriapp/screens/forms/signUp_screen.dart';
import 'package:farmeragriapp/screens/views/farmer/splash_screen.dart';
import 'package:farmeragriapp/screens/views/marketingOfficer/add_soilReport.dart';
import 'package:farmeragriapp/screens/views/marketingOfficer/manageFarmersScreen.dart';
import 'package:farmeragriapp/screens/views/marketingOfficer/officerDashboard.dart';
import 'package:farmeragriapp/screens/views/marketingOfficer/officer_profile.dart';
import 'package:farmeragriapp/screens/views/buyer/buyer_profile.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChannels.skia.invokeMethod('Skia.setAllowOpenGL', true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.green),
      initialRoute: "/",
      routes: {
        "/": (context) => const SplashScreen(),
        "/signIn": (context) => const SignInScreen(),
        "/signUp": (context) => const SignupScreen(),
        "/cultivational": (context) => const CultivationalScreen(),
        "/crop_updates": (context) => const CropDetailsScreen(),
        "/expenses": (context) => const CultivationalExpense(),
        "/inqueries": (context) => const InqueriesScreen(),
        "/addCultivational": (context) => const CultivationalAddScreen(),
        "/newcropupdate": (context) => const NewUpdateForm(),
        "/addExpenses": (context) => const AddExpense(),
        "/general": (context) => const GeneralIScreen(),
        "/commiunity": (context) => const CommiunityIscreen(),
        "/finacial": (context) => const FinancialIscreen(),
        "/technical": (context) => const TechnicalIScreen(),
        "/myTechnical": (context) => const TechnicalInquiryList(
            baseUrl: 'http://192.168.8.125:5000/api'),
        '/buyerDashboard': (context) => const BuyerDashboard(),
        '/buyer_profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          return BuyerProfileScreen(
            userId: args?['userId'] ?? '',
            userType: args?['userType'] ?? 'Buyer',
          );
        },
        // '/browse_products': (context) => const BrowseProductsScreen(),
        '/officerDashboard': (context) => const OfficerDashboard(
              userId: '',
            ),
        '/createFarmer': (context) => const CreateFarmerScreen(),
        "/updateFarmer": (context) => const UpdateFarmerScreen(),
        "/uploadSoilTestReport": (context) => const UploadSoilTestReportScreen(
              farmerId: '',
            ),
        "/manageFarmers": (context) => const ManageFarmersScreen(),
        "/officerProfile": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          return OfficerProfileScreen(
            userId: args?['userId'] ?? '',
            userType: args?['userType'] ?? 'Marketing Officer',
          );
        },
        // "/stock": (context) => const StockListScreen(),
        "/addHarvest": (context) => const AddHarvestScreen(),
        "/getHarvest": (context) => const FarmerStockScreen(),
        "/products": (context) => const OurProductsScreen(),
      },
    );
  }
}
