import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ClimaDeviationApp());
}

class ClimaDeviationApp extends StatelessWidget {
  const ClimaDeviationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClimaDéviation jg WebApp',
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
