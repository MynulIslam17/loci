import 'package:flutter/material.dart';

abstract class AppTextStyle {
  // Matches the 'family' name matches pubspec.yaml
  static const String _fontFamily = 'Inter';

  // --- Display 2xl (approx 72px) ---
  static TextStyle display2xl({Color? color, FontWeight weight = FontWeight.w400}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 72,
      fontWeight: weight,
      color: color,
    );
  }

  // --- Display xl (approx 60px) ---
  static TextStyle displayXl({Color? color, FontWeight weight = FontWeight.w400}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 60,
      fontWeight: weight,
      color: color,
    );
  }

  // --- Display lg (approx 48px) ---
  static TextStyle displayLg({Color? color, FontWeight weight = FontWeight.w400}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 48,
      fontWeight: weight,
      color: color,
    );
  }

  // --- Display md (approx 36px) ---
  static TextStyle displayMd({Color? color, FontWeight weight = FontWeight.w400}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 36,
      fontWeight: weight,
      color: color,
    );
  }

  // --- Display sm (approx 30px) ---
  static TextStyle displaySm({Color? color, FontWeight weight = FontWeight.w400}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 30,
      fontWeight: weight,
      color: color,
    );
  }

  // --- Display xs (approx 24px) ---
  static TextStyle displayXs({Color? color, FontWeight weight = FontWeight.w400}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: weight,
      color: color,
    );
  }

  // --- Standard Text (Text xl, lg, md, sm) ---

  static TextStyle textXl({Color? color, FontWeight weight = FontWeight.w400}) {
    return TextStyle(fontFamily: _fontFamily, fontSize: 20, fontWeight: weight, color: color);
  }

  static TextStyle textLg({Color? color, FontWeight weight = FontWeight.w400}) {
    return TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: weight, color: color);
  }

  static TextStyle textMd({Color? color, FontWeight weight = FontWeight.w400}) {
    return TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: weight, color: color);
  }

  static TextStyle textSm({Color? color, FontWeight weight = FontWeight.w400}) {
    return TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: weight, color: color);
  }

  static TextStyle textXs({Color? color, FontWeight weight = FontWeight.w400}) {
    return TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: weight, color: color);
  }
}