import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../models/appointment_model.dart';
import 'appointments_remote_datasource.dart';

class AppointmentsRemoteDataSourceImpl implements AppointmentsRemoteDataSource {
  AppointmentsRemoteDataSourceImpl({http.Client? client})
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

  @override
  Future<List<AppointmentModel>> listAppointments({String? status}) async {
    var uri = Uri.parse('$_base${ApiConstants.garageAppointments}');
    if (status != null && status.isNotEmpty) {
      uri = uri.replace(queryParameters: {'status': status});
    }
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(ApiConstants.connectionTimeout);
    final body = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final err = body is Map ? (body['error'] as String?) : null;
      throw ServerException(err ?? 'Failed to load appointments');
    }
    final list = body is List ? body : (body['data'] is List ? body['data'] as List : <dynamic>[]);
    return list
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AppointmentModel> getAppointment(String id) async {
    final uri = Uri.parse('$_base${ApiConstants.garageAppointmentById(id)}');
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(ApiConstants.connectionTimeout);
    final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
    if (response.statusCode != 200) {
      throw ServerException(body['error'] as String? ?? 'Failed to load appointment');
    }
    return AppointmentModel.fromJson(body);
  }

  @override
  Future<AppointmentModel> approveAppointment(String id) async {
    final uri = Uri.parse('$_base${ApiConstants.garageAppointmentApprove(id)}');
    final response = await _client
        .patch(uri, headers: _headers)
        .timeout(ApiConstants.connectionTimeout);
    final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
    if (response.statusCode != 200) {
      throw ServerException(body['error'] as String? ?? 'Failed to approve');
    }
    return AppointmentModel.fromJson(body);
  }

  @override
  Future<AppointmentModel> rejectAppointment(String id) async {
    final uri = Uri.parse('$_base${ApiConstants.garageAppointmentReject(id)}');
    final response = await _client
        .patch(uri, headers: _headers)
        .timeout(ApiConstants.connectionTimeout);
    final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
    if (response.statusCode != 200) {
      throw ServerException(body['error'] as String? ?? 'Failed to reject');
    }
    return AppointmentModel.fromJson(body);
  }

  @override
  Future<AppointmentModel> updateStatus(String id, String status) async {
    final uri = Uri.parse('$_base${ApiConstants.garageAppointmentStatus(id)}');
    final response = await _client
        .patch(
          uri,
          headers: _headers,
          body: jsonEncode({'status': status}),
        )
        .timeout(ApiConstants.connectionTimeout);
    final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
    if (response.statusCode != 200) {
      throw ServerException(body['error'] as String? ?? 'Failed to update status');
    }
    return AppointmentModel.fromJson(body);
  }
}
