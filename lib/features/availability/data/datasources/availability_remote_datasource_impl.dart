import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/auth/session_invalidation.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../models/availability_slot_model.dart';
import 'availability_remote_datasource.dart';

class AvailabilityRemoteDataSourceImpl implements AvailabilityRemoteDataSource {
  AvailabilityRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  String get _base => kApiBaseUrl;

  void _throwUnauthorizedIfNeeded(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      reportUnauthorizedHttpStatus(statusCode);
      throw const UnauthorizedException();
    }
  }

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

  @override
  Future<List<AvailabilitySlotModel>> listSlots({String? dayOfWeek}) async {
    var uri = Uri.parse('$_base${ApiConstants.garageAvailabilityMeSlots}');
    if (dayOfWeek != null && dayOfWeek.isNotEmpty) {
      uri = uri.replace(queryParameters: {'dayOfWeek': dayOfWeek});
    }
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(ApiConstants.connectionTimeout);
    _throwUnauthorizedIfNeeded(response.statusCode);
    final body = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final err = body is Map ? (body['error'] as String?) : null;
      throw ServerException(err ?? 'Failed to load availability');
    }
    final list = body is List ? body : (body['data'] is List ? body['data'] as List : <dynamic>[]);
    return list
        .map((e) => AvailabilitySlotModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AvailabilitySlotModel> createSlot({
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final uri = Uri.parse('$_base${ApiConstants.garageAvailabilityMeSlots}');
    final response = await _client
        .post(
          uri,
          headers: _headers,
          body: jsonEncode({
            'dayOfWeek': dayOfWeek,
            'startTime': startTime,
            'endTime': endTime,
          }),
        )
        .timeout(ApiConstants.connectionTimeout);
    final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
    _throwUnauthorizedIfNeeded(response.statusCode);
    if (response.statusCode != 201) {
      throw ServerException(body['error'] as String? ?? 'Failed to create slot');
    }
    return AvailabilitySlotModel.fromJson(body);
  }

  @override
  Future<AvailabilitySlotModel> updateSlot(
    String id, {
    String? dayOfWeek,
    String? startTime,
    String? endTime,
  }) async {
    final uri = Uri.parse('$_base${ApiConstants.garageAvailabilityMeSlotById(id)}');
    final map = <String, dynamic>{};
    if (dayOfWeek != null) map['dayOfWeek'] = dayOfWeek;
    if (startTime != null) map['startTime'] = startTime;
    if (endTime != null) map['endTime'] = endTime;
    final response = await _client
        .patch(uri, headers: _headers, body: jsonEncode(map))
        .timeout(ApiConstants.connectionTimeout);
    final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
    _throwUnauthorizedIfNeeded(response.statusCode);
    if (response.statusCode != 200) {
      throw ServerException(body['error'] as String? ?? 'Failed to update slot');
    }
    return AvailabilitySlotModel.fromJson(body);
  }

  @override
  Future<void> deleteSlot(String id) async {
    final uri = Uri.parse('$_base${ApiConstants.garageAvailabilityMeSlotById(id)}');
    final response = await _client
        .delete(uri, headers: _headers)
        .timeout(ApiConstants.connectionTimeout);
    _throwUnauthorizedIfNeeded(response.statusCode);
    if (response.statusCode != 204 && response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final err = body is Map ? (body['error'] as String?) : null;
      throw ServerException(err ?? 'Failed to delete slot');
    }
  }
}
