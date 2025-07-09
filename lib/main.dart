import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';

// This custom scroll behavior enables touch-based scrolling on web platforms,
// which provides a more natural, app-like experience for mobile web users.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

void main() async {
  // It's good practice to ensure widgets are initialized before running the app,
  // especially when using async operations in main().
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for the French locale so it's available
  // throughout the app.
  await initializeDateFormatting('fr_FR', null);

  runApp(const ClimaDeviationApp());
}

class ClimaDeviationApp extends StatelessWidget {
  const ClimaDeviationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClimaDéviation jg WebApp',
      // Apply the custom scroll behavior to the entire app.
      scrollBehavior: AppScrollBehavior(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}