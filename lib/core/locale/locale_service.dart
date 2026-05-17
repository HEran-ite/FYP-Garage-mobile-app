import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and resolves the user's preferred app locale.
class LocaleService {
  LocaleService(this._prefs);

  static const String localeKey = 'app_locale';

  final SharedPreferences _prefs;

  static const Locale english = Locale('en');
  static const Locale amharic = Locale('am');

  static const List<Locale> supportedLocales = [english, amharic];

  Locale? get savedLocale {
    final code = _prefs.getString(localeKey);
    if (code == null) return null;
    return Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(localeKey, locale.languageCode);
  }
}
