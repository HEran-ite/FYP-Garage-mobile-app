import 'package:flutter/material.dart';
import '../constants/font_sizes.dart';
import '../constants/font_weights.dart';
import 'app_colors.dart';

/// App-wide text styles
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get headlineLarge => TextStyle(
        fontSize: AppFontSizes.xxxl,
        fontWeight: AppFontWeights.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontSize: AppFontSizes.xxl,
        fontWeight: AppFontWeights.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => TextStyle(
        fontSize: AppFontSizes.xl,
        fontWeight: AppFontWeights.semiBold,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: AppFontSizes.lg,
        fontWeight: AppFontWeights.regular,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: AppFontSizes.md,
        fontWeight: AppFontWeights.regular,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: AppFontSizes.sm,
        fontWeight: AppFontWeights.regular,
        color: AppColors.textSecondary,
      );
}

