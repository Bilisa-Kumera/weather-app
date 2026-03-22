import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF3563E9),
        secondary: const Color(0xFF68B9FF),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3563E9),
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark();
    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      textTheme: textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF4F7CFF),
        secondary: const Color(0xFF68B9FF),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F7CFF),
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
