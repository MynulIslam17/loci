import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes {
  AppThemes._();

  // --- LIGHT THEME ---
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      surface: AppColors.background,        // Pure white from image
      onSurface: AppColors.dark900,         // Main Text (Darkest Gray)
      onSurfaceVariant: AppColors.neutral900, // Subtitles / Hint Text

      primary: AppColors.primaryG400,        // Main Teal
      onPrimary: AppColors.base100,              // Text ON Buttons
      primaryContainer: AppColors.primary100, // Soft Teal for splash/containers

      secondary: AppColors.primaryG500,     // Primary-G Green/Teal
      onSecondary: Colors.white,

      outline: AppColors.base600,           // Light borders
      error: AppColors.danger,              // Status Red
      surfaceContainerHigh: AppColors.base100, // Card background

      surfaceContainer: AppColors.base500, //works on card (on light mode show light dark)


    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.base500,
      foregroundColor: AppColors.dark900,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 3,            // Shadow appears when content scrolls under
      surfaceTintColor: Colors.transparent, // Required for real shadow in M3
    ),
  );

  // --- DARK THEME ---
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: AppColors.dark900,           // Dark Background (#141414)
      onSurface: AppColors.base50,          // Bright Text (#F9FAFB)
      onSurfaceVariant: AppColors.neutral500, // Muted Text

      primary: AppColors.primaryG400,       // Vibrant Teal for Dark Mode
      onPrimary: AppColors.dark900,
      primaryContainer: AppColors.dark500,  // Background for containers

      secondary: AppColors.primaryG500,
      outline: AppColors.dark400,           // Darker borders
      surfaceContainerHigh: AppColors.dark500, // Card Backgrounds
      error: AppColors.danger,

      surfaceContainer: AppColors.dark800,//works on card (on dark mode show deep dark)


    ),

    appBarTheme: const AppBarTheme(
      backgroundColor:AppColors.dark500,
      foregroundColor: AppColors.base50,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 3,
      surfaceTintColor: Colors.transparent,
    ),
  );
}