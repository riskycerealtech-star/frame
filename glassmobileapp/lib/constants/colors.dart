import 'package:flutter/material.dart';

class AppColors {
  // Main app color
  static const Color primary = Color(0xFF24577c);
  
  // Color variations based on main color
  static const Color primaryLight = Color(0xFF4a7a9a);
  static const Color primaryDark = Color(0xFF1e4a6b);
  static const Color primaryDarker = Color(0xFF153a55);
  
  // Complementary colors
  static const Color secondary = Color(0xFFf4a261);
  static const Color accent = Color(0xFFe76f51);
  
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFFF3F4F6);
  static const Color darkGrey = Color(0xFF374151);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F9FA);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  
  // Border colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  
  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF24577c),
    Color(0xFF4a7a9a),
    Color(0xFF1e4a6b),
  ];
  
  static const List<Color> backgroundGradient = [
    Color(0xFF24577c),
    Color(0xFF4a7a9a),
    Color(0xFFf0f8ff),
  ];
  
  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
}

class AppColorScheme {
  static ColorScheme get lightColorScheme {
    return const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.primaryLight,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimary,
      onError: AppColors.white,
    );
  }
  
  static ColorScheme get darkColorScheme {
    return const ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.primaryDark,
      surface: AppColors.darkGrey,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
      onError: AppColors.white,
    );
  }
}
