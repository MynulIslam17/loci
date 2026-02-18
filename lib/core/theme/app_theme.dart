import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes {
  AppThemes._();

  // --- LIGHT THEME ---
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primaryContainer:AppColors.primaryG50,// for splash (and some other background)
      surface: AppColors.base50,           // Page Background
      onSurface: AppColors.dark900,        // Main Text
      onSurfaceVariant: AppColors.neutral900, // Subtitles / Hint Text
      primary: AppColors.primary500,       // Buttons / Active States
      onPrimary: Colors.white,             // Text ON Buttons
      secondary: AppColors.primaryG500,     // Accents / Badges
      outline: AppColors.dark50,           // Borders / Dividers
      error: AppColors.danger,             // Error states
      surfaceContainerHigh: AppColors.base500,// card
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.base500,
      foregroundColor: AppColors.dark500,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,

    )
  );

  // --- DARK THEME ---
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primaryContainer: Color(0xff272727), // for splash
      surface: AppColors.dark900,      // Dark Background
      onSurface: AppColors.darkText,       // Bright Main Text
      onSurfaceVariant: AppColors.darkTextSecondary, // Muted Text
      primary: AppColors.primaryDark,      // Vibrant Teal Buttons
      onPrimary: AppColors.dark900,        // Dark Text ON Teal Buttons
      secondary: AppColors.primaryDarkMuted, // Muted Accents
      outline: AppColors.darkBorder,       // Dark Borders
      surfaceContainerHigh: AppColors.dark500, // Card Backgrounds
      error: AppColors.danger,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.dark500,
      foregroundColor: AppColors.base500,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,

    )
  );
}