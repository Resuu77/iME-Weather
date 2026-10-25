import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  // ── Glassmorphism spec ────────────────────────────────────────────────────
  static const double kBlurSigma = 22.0;
  static const double kCardRadius = 24.0;
  static const Color kGlassBorder = Color(0x40FFFFFF); // 25% white
  static const Color kGlassFill = Color(0x26FFFFFF);   // 15% white
  static const Color kGlassFillDark = Color(0x1AFFFFFF); // 10% white for inner sections

  static const List<BoxShadow> kCardShadows = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 30,
      spreadRadius: -4,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x10FFFFFF),
      blurRadius: 1,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  // ── Text styles ───────────────────────────────────────────────────────────
  static const String fontFamily = 'SFPro';

  static TextTheme get textTheme => const TextTheme(
        // Temperature display
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 88,
          fontWeight: FontWeight.w200,
          color: Colors.white,
          height: 1.0,
          letterSpacing: -4,
        ),
        // City name / section header
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
        // Weather status label
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Color(0xCCFFFFFF),
          letterSpacing: 0.1,
        ),
        // Card sub-headers
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xB3FFFFFF),
          letterSpacing: 1.2,
        ),
        // Normal body text in cards
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xCCFFFFFF),
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xB3FFFFFF),
          letterSpacing: 0.1,
        ),
      );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        textTheme: textTheme,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      );
}
