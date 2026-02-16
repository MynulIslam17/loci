import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppThemes {
  // --- LIGHT THEME ---
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      surface: AppColors.base50,
      onSurface: AppColors.dark900,         // Main Text
      onSurfaceVariant: AppColors.neutral900, // Hint Text / Icons
      primary: AppColors.primary500,
      onPrimary: Colors.white,
      secondary: AppColors.primaryG500,
      outline: AppColors.dark50,            // Border colors
    ),
  );

  // --- DARK THEME ---
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: AppColors.darkSurface,       // Softer dark background
      onSurface: AppColors.darkText,        // Easy-to-read light text
      onSurfaceVariant: AppColors.darkTextSecondary, // Subtle secondary text
      primary: AppColors.primaryDark,       // Vibrant teal for dark mode
      onPrimary: AppColors.dark900,         // Dark text on primary buttons
      secondary: AppColors.primaryDarkMuted,// Muted teal accent
      outline: AppColors.darkBorder,        // Subtle borders
      surfaceContainerHighest: AppColors.darkCard, // For cards/elevated surfaces
    ),
  );
}