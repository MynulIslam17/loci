import 'package:flutter/material.dart';

abstract class AppTextStyle {
  // Matches the 'family' name matches pubspec.yaml
  static const String _fontFamily = 'Inter';

  // --- Display 2xl (approx 72px) ---
  static TextStyle display2xl({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.15,
    double? letterSpacing = -1.5,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 72,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // --- Display xl (approx 60px) ---
  static TextStyle displayXl({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.15,
    double? letterSpacing = -1.2,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 60,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // --- Display lg (approx 48px) ---
  static TextStyle displayLg({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.15,
    double? letterSpacing = -1.0,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 48,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // --- Display md (approx 36px) ---
  static TextStyle displayMd({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.2,
    double? letterSpacing = -0.8,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 36,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // --- Display sm (approx 30px) ---
  static TextStyle displaySm({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.25,
    double? letterSpacing = -0.5,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 30,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // --- Display xs (approx 24px) ---
  static TextStyle displayXs({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.25,
    double? letterSpacing = -0.3,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // --- Standard Text (Text xl, lg, md, sm, xs) ---

  static TextStyle textXl({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.3,
    double? letterSpacing = -0.2,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle textLg({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.35,
    double? letterSpacing = -0.15,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 18,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle textMd({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.4,
    double? letterSpacing = 0.0,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle textSm({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.4,
    double? letterSpacing = 0.0,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle textXs({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.4,
    double? letterSpacing = 0.0,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}