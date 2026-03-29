import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/auth/session_invalidation.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'garage_settings_remote_datasource.dart';

class GarageSettingsRemoteDataSourceImpl implements GarageSettingsRemoteDataSource {
  GarageSettingsRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  String get _base => kApiBaseUrl;

  Map<String, String> get _headers {
    final token = authToken;
    if (token == null || token.isEmpty) {
      throw const ServerException('Not authenticated. Please sign in again.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _parseObject(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return <String, dynamic>{};
    if (trimmed.startsWith('<!') || trimmed.toLowerCase().startsWith('<html')) {
      throw const ServerException(
        'Server returned an error page instead of data. Check that the API URL is correct and the backend is running.',
      );
    }
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{};
    } on FormatException catch (e) {
      throw ServerException('Invalid server response: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getSettings() async {
    final uri = Uri.parse('$_base${ApiConstants.garageSettings}');
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(ApiConstants.connectionTimeout);
    final decoded = _parseObject(response.body);
    if (response.statusCode != 200) {
      reportUnauthorizedHttpStatus(response.statusCode);
      final err = decoded['error']?.toString() ?? 'Failed to load settings';
      throw ServerException(err);
    }
    return decoded;
  }

  @override
  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> patch) async {
    final uri = Uri.parse('$_base${ApiConstants.garageSettings}');
    final response = await _client
        .put(
          uri,
          headers: _headers,
          body: jsonEncode(patch),
        )
        .timeout(ApiConstants.connectionTimeout);
    final decoded = _parseObject(response.body);
    if (response.statusCode != 200) {
      reportUnauthorizedHttpStatus(response.statusCode);
      final err = decoded['error']?.toString() ?? 'Failed to update settings';
      throw ServerException(err);
    }
    return decoded;
  }
}

