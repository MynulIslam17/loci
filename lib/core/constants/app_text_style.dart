import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyle {
  // --- Display 2xl (approx 72px based on standard scales) ---
  static TextStyle display2xl({Color? color, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.inter(
      fontSize: 72,
      fontWeight: weight,
      color: color,
    );
  }

  // --- Display xl (approx 60px) ---
  static TextStyle displayXl({Color? color, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.inter(
      fontSize: 60,
      fontWeight: weight,
      color: color,
    );
  }

  // --- Display lg (approx 48px) ---
  static TextStyle displayLg({Color? color, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.inter(
      fontSize: 48,
      fontWeight: weight,
      color: color,
    );
  }

  // --- Display md (approx 36px) ---
  static TextStyle displayMd({Color? color, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.inter(
      fontSize: 36,
      fontWeight: weight,
      color: color,
    );
  }

  // --- Display sm (approx 30px) ---
  static TextStyle displaySm({Color? color, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.inter(
      fontSize: 30,
      fontWeight: weight,
      color: color,
    );
  }

  // --- Display xs (approx 24px) ---
  static TextStyle displayXs({Color? color, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: weight,
      color: color,
    );
  }

  // --- Standard Text (Text xl, lg, md, sm) ---

  static TextStyle textXl({Color? color, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.inter(fontSize: 20, fontWeight: weight, color: color);
  }

  static TextStyle textLg({Color? color, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.inter(fontSize: 18, fontWeight: weight, color: color);
  }

  static TextStyle textMd({Color? color, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.inter(fontSize: 16, fontWeight: weight, color: color);
  }

  static TextStyle textSm({Color? color, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.inter(fontSize: 14, fontWeight: weight, color: color);
  }

  static TextStyle textXs({Color? color, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.inter(fontSize: 12, fontWeight: weight, color: color);
  }
}