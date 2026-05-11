import 'package:flutter/material.dart';

class AppTheme {
  // Psychological Colors for Learning
  static const Color navyBlue = Color(0xFF1A237E); // Deep focus
  static const Color midnightBlue = Color(0xFF0D1B2A); // Background
  static const Color forestGreen = Color(0xFF2D6A4F); // Progress/Done
  static const Color sageGreen = Color(0xFF52B788); // Success highlights
  static const Color offWhite = Color(0xFFF8F9FA); // Contrast text/bg
  static const Color softGray = Color(0xFFE9ECEF); // Secondary elements

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: navyBlue,
      scaffoldBackgroundColor: offWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: navyBlue,
        primary: navyBlue,
        secondary: forestGreen,
        surface: offWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: midnightBlue,
        selectedIconTheme: IconThemeData(color: sageGreen),
        unselectedIconTheme: IconThemeData(color: Colors.white70),
        selectedLabelTextStyle: TextStyle(color: sageGreen, fontWeight: FontWeight.bold),
        unselectedLabelTextStyle: TextStyle(color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: midnightBlue, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: midnightBlue),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: navyBlue,
      scaffoldBackgroundColor: midnightBlue,
      colorScheme: const ColorScheme.dark(
        primary: navyBlue,
        secondary: sageGreen,
        surface: Color(0xFF1B263B),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Color(0xFF0B132B),
        selectedIconTheme: IconThemeData(color: sageGreen),
        unselectedIconTheme: IconThemeData(color: Colors.white54),
      ),
    );
  }
}
