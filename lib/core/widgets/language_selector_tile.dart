import 'package:flutter/material.dart';

import '../locale/l10n_extension.dart';
import '../theme/app_colors.dart';
import 'language_dropdown_button.dart';

/// Settings row to switch between English and Amharic.
class LanguageSelectorTile extends StatelessWidget {
  const LanguageSelectorTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.language, color: AppColors.textSecondary),
      title: Text(
        l10n.language,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
      ),
      trailing: const LanguageDropdownButton(),
    );
  }
}
