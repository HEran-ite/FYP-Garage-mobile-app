import 'package:flutter/material.dart';
import '../constants/border_radius.dart';
import '../constants/spacing.dart';
import 'app_colors.dart';

/// Common box decorations
class AppDecorations {
  AppDecorations._();

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      contentPadding: const EdgeInsets.all(AppSpacing.md),
    );
  }
}

