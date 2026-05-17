import 'package:flutter/material.dart';

import 'locale_service.dart';

/// Provides locale switching to descendants (e.g. profile language picker).
class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    super.key,
    required this.locale,
    required this.setLocale,
    required super.child,
  });

  final Locale locale;
  final Future<void> Function(Locale locale) setLocale;

  static AppLocaleScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) =>
      oldWidget.locale != locale;
}

/// Resolves initial locale: saved preference, else device language if Amharic.
Locale resolveInitialLocale(LocaleService service) {
  final saved = service.savedLocale;
  if (saved != null) return saved;
  final device = WidgetsBinding.instance.platformDispatcher.locale;
  if (device.languageCode == 'am') return LocaleService.amharic;
  return LocaleService.english;
}
