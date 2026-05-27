import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  /// When `true` the theme avoids `GoogleFonts` entirely. Set this from
  /// integration tests (where the emulator has no network / no bundled
  /// font asset) so font loading never throws asynchronously and corrupts
  /// the test binding state.
  static bool disableGoogleFonts = false;

  static String? get _fontFamily {
    if (disableGoogleFonts) return null;
    try {
      return GoogleFonts.inter().fontFamily;
    } catch (_) {
      return null;
    }
  }

  static ThemeData get lightTheme {
    final fontFamily = _fontFamily;
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge.copyWith(fontFamily: fontFamily),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(fontFamily: fontFamily),
        titleLarge: AppTextStyles.titleLarge.copyWith(fontFamily: fontFamily),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(fontFamily: fontFamily),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(fontFamily: fontFamily),
        bodySmall: AppTextStyles.bodySmall.copyWith(fontFamily: fontFamily),
      ),
      scaffoldBackgroundColor: AppColors.surface,
    );
  }

  static ThemeData get darkTheme {
    final fontFamily = _fontFamily;
    if (disableGoogleFonts) {
      return ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryLight,
          secondary: AppColors.secondaryLight,
          error: AppColors.error,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.textPrimary,
      );
    }
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
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

