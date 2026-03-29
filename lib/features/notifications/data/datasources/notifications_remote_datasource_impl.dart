import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/auth/session_invalidation.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../models/notification_model.dart';
import 'notifications_remote_datasource.dart';

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  String get _base => kApiBaseUrl;

  static dynamic _parseJson(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return <dynamic>[];
    if (trimmed.startsWith('<!') || trimmed.toLowerCase().startsWith('<html')) {
      throw const ServerException(
        'Server returned an error page. Check that the API URL is correct.',
      );
    }
    try {
      return jsonDecode(trimmed);
    } on FormatException catch (e) {
      throw ServerException('Invalid server response: ${e.message}');
    }
  }

  @override
  Future<List<NotificationModel>> listNotifications() async {
    final uri = Uri.parse('$_base${ApiConstants.garageNotifications}');
    final token = authToken;
    if (token == null || token.isEmpty) {
      throw const ServerException('Not authenticated');
    }
    final response = await _client
        .get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(ApiConstants.connectionTimeout);

    final decoded = _parseJson(response.body);
    if (response.statusCode != 200) {
      reportUnauthorizedHttpStatus(response.statusCode);
      final body = decoded is Map ? decoded as Map<String, dynamic> : <String, dynamic>{};
      final err = body['error']?.toString() ?? 'Failed to load notifications';
      throw ServerException(err);
    }
    final list = decoded is List ? decoded : (decoded is Map && decoded['data'] is List ? decoded['data'] as List : <dynamic>[]);
    return list
        .where((e) => e is Map)
        .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
