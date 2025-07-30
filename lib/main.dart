import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/customer_home_screen.dart';
import 'screens/staff_home_screen.dart';
import 'screens/home_menu.dart';
import 'screens/park_car_screen.dart';
import 'screens/send_barrel_screen.dart';
import 'screens/transport_car_screen.dart';
import 'screens/sell_cars_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/car_details_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/add_staff_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/parking_records_screen.dart';
import 'screens/package_records_screen.dart';
import 'screens/transport_records_screen.dart';
import 'screens/sales_records_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: Consumer2<LanguageProvider, AuthProvider>(
        builder: (context, languageProvider, authProvider, child) {
          return MaterialApp(
            title: 'TAAO Auto',
            locale: languageProvider.currentLocale,
            supportedLocales: const [
              Locale('en'), // English
              Locale('fr'), // French
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B365D)),
              useMaterial3: true,
              primaryColor: const Color(0xFF1B365D),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1B365D),
                foregroundColor: Colors.white,
              ),
            ),
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/': (context) => const CustomerHomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/car-details': (context) {
                final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                final carId = args?['carId'] as String? ?? '';
                return CarDetailsScreen(carId: carId);
              },
              // Staff-only routes (hidden from customers)
              '/staff-home': (context) => const StaffHomeScreen(),
              '/home-menu': (context) => const HomeMenu(),
              '/park': (context) => const ParkCarScreen(),
              '/barrel': (context) => const SendBarrelScreen(),
              '/transport': (context) => const TransportCarScreen(),
              '/sell': (context) => const SellCarsScreen(),
              '/tracking': (context) => const TrackingScreen(),
              '/user-management': (context) => const UserManagementScreen(),
              '/add-staff': (context) => const AddStaffScreen(),
              '/change-password': (context) => const ChangePasswordScreen(),
              '/parking-records': (context) => const ParkingRecordsScreen(),
              '/package-records': (context) => const PackageRecordsScreen(),
              '/transport-records': (context) => const TransportRecordsScreen(),
              '/sales-records': (context) => const SalesRecordsScreen(),
            },
          );
        },
      ),
    );
  }
}
