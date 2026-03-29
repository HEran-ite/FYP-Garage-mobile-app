import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

/// Persists auth token and user to SharedPreferences so session survives app restart.
/// Token is stored until logout or app uninstall (no client-side expiry).
abstract class AuthSessionStorage {
  Future<void> save(String token, UserModel user);
  Future<void> clear();
  Future<({String token, UserModel user})?> load();
}

class AuthSessionStorageImpl implements AuthSessionStorage {
  AuthSessionStorageImpl({Future<SharedPreferences>? prefs})
      : _prefs = prefs ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _prefs;

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  /// Catch PlatformException (e.g. channel not ready on Android) so app doesn't crash.
  static Future<SharedPreferences?> _getPrefs(Future<SharedPreferences> future) async {
    try {
      return await future;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<void> save(String token, UserModel user) async {
    SharedPreferences? prefs = await _getPrefs(_prefs);
    if (prefs == null) {
      await Future.delayed(const Duration(milliseconds: 100));
      prefs = await _getPrefs(_prefs);
    }
    try {
      if (prefs == null) return;
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    } on PlatformException {
      // Channel not ready or storage unavailable; skip persist
    }
  }

  @override
  Future<void> clear() async {
    try {
      final prefs = await _getPrefs(_prefs);
      if (prefs == null) return;
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUser);
    } on PlatformException {
      // Channel not ready or storage unavailable
    }
  }

  @override
  Future<({String token, UserModel user})?> load() async {
    try {
      SharedPreferences? prefs = await _getPrefs(_prefs);
      if (prefs == null) {
        await Future.delayed(const Duration(milliseconds: 100));
        prefs = await _getPrefs(_prefs);
      }
      if (prefs == null) return null;
      final token = prefs.getString(_keyToken);
      final userJson = prefs.getString(_keyUser);
      if (token == null || token.isEmpty || userJson == null || userJson.isEmpty) {
        return null;
      }
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      final user = UserModel.fromJson(map);
      return (token: token, user: user);
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
