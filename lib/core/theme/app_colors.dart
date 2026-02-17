import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Base Colors (Light Grays/Whites) ---
  static const Color base50  = Color(0xFFFBFBFB);
  static const Color base500 = Color(0xFFF9F9F9);
  static const Color base900 = Color(0xFFB7B7B7);

  // --- Dark Colors (Deep Grays/Blacks) ---
  static const Color dark50  = Color(0xFFEBEBEB);
  static const Color dark500 = Color(0xFF272727);
  static const Color dark900 = Color(0xFF141414);

  // --- Neutral Colors ---
  static const Color neutral50  = Color(0xFFF5F5F9);
  static const Color neutral500 = Color(0xFF9CB0B9);
  static const Color neutral900 = Color(0xFF424242);

  // --- Primary G (Teal/Greenish) ---
  static const Color primaryG50  = Color(0xFFa1d6d1);
  static const Color primaryG500 = Color(0xFF32A58E);
  static const Color primaryG900 = Color(0xFF1B3B31);

  // --- Primary (Deep Teal) ---
  static const Color primary100 = Color(0xFFD7EAEB);
  static const Color primary500 = Color(0xFF22A89A);
  static const Color primary900 = Color(0xFF273F4C);

  // --- Status Colors ---
  static const Color success = Color(0xFF4CAF50);
  static const Color danger  = Color(0xFFF22C2D);

  // --- Additional Dark Mode Colors ---
  static const Color darkSurface = Color(0xFF1A1A1A);      // Softer than dark900
  static const Color darkCard = Color(0xFF242424);         // For elevated surfaces
  static const Color darkBorder = Color(0xFF2F2F2F);       // Subtle borders
  static const Color darkText = Color(0xFFE8E8E8);         // Easy on eyes
  static const Color darkTextSecondary = Color(0xFFAAAAAA); // Secondary text

  // --- Dark Mode Primary (Brighter Teal) ---
  static const Color primaryDark = Color(0xFF3DCAB8);      // Vibrant teal for dark
  static const Color primaryDarkMuted = Color(0xFF2A9D8F); // Muted version
}