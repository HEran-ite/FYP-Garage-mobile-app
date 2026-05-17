import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../constants/border_radius.dart';
import '../locale/app_locale_scope.dart';
import '../locale/l10n_extension.dart';
import '../locale/locale_service.dart';
import '../theme/app_colors.dart';

/// Compact language picker sized to its label (login + settings).
class LanguageDropdownButton extends StatelessWidget {
  const LanguageDropdownButton({super.key});

  static const double _height = 40;
  static const double _horizontalPadding = 14;

  String _labelFor(Locale locale, AppLocalizations l10n) =>
      locale.languageCode == 'am' ? l10n.languageAmharic : l10n.languageEnglish;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = AppLocaleScope.of(context).locale;
    final selected = current.languageCode == 'am'
        ? LocaleService.amharic
        : LocaleService.english;

    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 1.2,
        );

    return PopupMenuButton<Locale>(
      initialValue: selected,
      tooltip: l10n.language,
      offset: const Offset(0, _height + 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        side: const BorderSide(color: AppColors.inputBorder),
      ),
      color: AppColors.surface,
      elevation: 4,
      onSelected: (locale) => AppLocaleScope.of(context).setLocale(locale),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: LocaleService.amharic,
          height: 44,
          child: Text(l10n.languageAmharic, style: labelStyle),
        ),
        PopupMenuItem(
          value: LocaleService.english,
          height: 44,
          child: Text(l10n.languageEnglish, style: labelStyle),
        ),
      ],
      child: Container(
        height: _height,
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_labelFor(selected, l10n), style: labelStyle),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
