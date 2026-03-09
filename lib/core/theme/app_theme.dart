import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  static String get _fontFamily => GoogleFonts.inter().fontFamily!;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge.copyWith(fontFamily: _fontFamily),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(fontFamily: _fontFamily),
        titleLarge: AppTextStyles.titleLarge.copyWith(fontFamily: _fontFamily),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(fontFamily: _fontFamily),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(fontFamily: _fontFamily),
        bodySmall: AppTextStyles.bodySmall.copyWith(fontFamily: _fontFamily),
      ),
      scaffoldBackgroundColor: AppColors.surface,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: AppColors.textPrimary,
    );
  }
}

