import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFDC143C);
  static const Color backgroundBlack = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF111111);
  static const Color cardGrey = Color(0xFF1A1A1A);
  static const Color borderGrey = Color(0xFF2A2A2A);
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFF9E9E9E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundBlack,
      primaryColor: primaryRed,
      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        secondary: primaryRed,
        surface: surfaceDark,
        onSurface: textWhite,
        error: primaryRed,
      ),
      dividerTheme: const DividerThemeData(
        color: borderGrey,
        thickness: 1,
      ),
      cardTheme: const CardThemeData(
        color: cardGrey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: textWhite, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: textWhite),
          bodyMedium: TextStyle(color: textWhite),
          labelLarge: TextStyle(color: textWhite),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryRed,
        unselectedItemColor: textGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get lightTheme {
    // Basic light theme if needed, but app is primarily dark
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryRed,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
    );
  }
}
