import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/locale/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/language_dropdown_button.dart';

/// Shared auth page shell: back, language, logo, step label, scrollable body.
class RegisterPageLayout extends StatelessWidget {
  const RegisterPageLayout({
    super.key,
    required this.onBack,
    required this.stepLabel,
    required this.body,
  });

  final VoidCallback onBack;
  final String stepLabel;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                  Expanded(
                    child: Text(
                      stepLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                  const LanguageDropdownButton(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.createAccount,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    body,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
