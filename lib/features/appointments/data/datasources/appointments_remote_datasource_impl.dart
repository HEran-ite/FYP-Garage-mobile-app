import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/auth/session_invalidation.dart';
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

  /// Parses response body as JSON. Throws [ServerException] if body is not valid JSON (e.g. HTML error page).
  static dynamic _parseJson(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return <String, dynamic>{};
    if (trimmed.startsWith('<!') || trimmed.toLowerCase().startsWith('<html')) {
      throw const ServerException(
        'Server returned an error page instead of data. Check that the API URL is correct and the backend is running.',
      );
    }
    try {
      return jsonDecode(trimmed);
    } on FormatException catch (e) {
      throw ServerException(
        'Invalid server response: ${e.message}. The server may not support this request.',
      );
    }
  }

  static Map<String, dynamic> _parseJsonObject(String body) {
    final decoded = _parseJson(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{};
  }

  static String _errorMessage(int statusCode, Map<String, dynamic> body, String fallback) {
    reportUnauthorizedHttpStatus(statusCode);
    if (statusCode >= 500) return 'Something went wrong. Please try again.';
    if (statusCode == 401 || statusCode == 403) return 'Please sign in again.';
    return body['error']?.toString() ?? body['message']?.toString() ?? fallback;
  }

  static bool _isSuccessStatus(int code) =>
      code == 200 || code == 201 || code == 204;

  /// Backend may return the appointment at top level, under `data`, or `data.appointment`.
  static Map<String, dynamic>? _unwrapAppointmentMap(Map<String, dynamic> m) {
    if (m['appointment'] is Map) {
      return Map<String, dynamic>.from(m['appointment'] as Map);
    }
    if (m['data'] is Map) {
      final d = Map<String, dynamic>.from(m['data'] as Map);
      if (d['appointment'] is Map) {
        return Map<String, dynamic>.from(d['appointment'] as Map);
      }
      if (d['id'] is String) return d;
    }
    if (m['id'] is String) return m;
    return null;
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
  Future<List<AppointmentModel>> listAppointments({String? status, String? search}) async {
    var uri = Uri.parse('$_base${ApiConstants.garageAppointments}');
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();
    if (queryParams.isNotEmpty) uri = uri.replace(queryParameters: queryParams);
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(ApiConstants.connectionTimeout);
    final decoded = _parseJson(response.body);
    if (response.statusCode != 200) {
      final errMap = decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
      throw ServerException(_errorMessage(response.statusCode, errMap, 'Failed to load appointments'));
    }
    final List list = decoded is List
        ? decoded
        : (decoded is Map && decoded['data'] is List)
            ? decoded['data'] as List
            : <dynamic>[];
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
    final body = _parseJsonObject(response.body);
    if (response.statusCode != 200) {
      throw ServerException(_errorMessage(response.statusCode, body, 'Failed to load appointment'));
    }
    final unwrapped = _unwrapAppointmentMap(body) ?? body;
    return AppointmentModel.fromJson(unwrapped);
  }

  /// Garage backend uses PATCH for approve/reject/status; PUT kept as fallback.
  Future<AppointmentModel> _modelAfterMutation(
    String id,
    http.Response response,
    String fallbackMsg,
  ) async {
    if (response.statusCode == 401) {
      final err = _parseJsonObject(response.body);
      throw ServerException(_errorMessage(401, err, fallbackMsg));
    }
    if (!_isSuccessStatus(response.statusCode)) {
      final body = _parseJsonObject(response.body);
      throw ServerException(
          _errorMessage(response.statusCode, body, fallbackMsg));
    }
    if (response.statusCode == 204 || response.body.trim().isEmpty) {
      return getAppointment(id);
    }
    final decoded = _parseJson(response.body);
    if (decoded is! Map) {
      return getAppointment(id);
    }
    final m = Map<String, dynamic>.from(decoded);
    final unwrapped = _unwrapAppointmentMap(m) ?? m;
    try {
      final model = AppointmentModel.fromJson(unwrapped);
      if (model.id.isEmpty) return getAppointment(id);
      return model;
    } catch (_) {
      return getAppointment(id);
    }
  }

  Future<http.Response> _patchThenPut(Uri uri, {String? body}) async {
    var response = await _client
        .patch(uri, headers: _headers, body: body)
        .timeout(ApiConstants.connectionTimeout);
    if (_isSuccessStatus(response.statusCode) || response.statusCode == 401) {
      return response;
    }
    return _client
        .put(uri, headers: _headers, body: body)
        .timeout(ApiConstants.connectionTimeout);
  }

  @override
  Future<AppointmentModel> approveAppointment(String id) async {
    final uri = Uri.parse('$_base${ApiConstants.garageAppointmentApprove(id)}');
    final response = await _patchThenPut(uri);
    return _modelAfterMutation(id, response, 'Failed to approve');
  }

  @override
  Future<AppointmentModel> rejectAppointment(String id) async {
    final uri = Uri.parse('$_base${ApiConstants.garageAppointmentReject(id)}');
    final response = await _patchThenPut(uri);
    return _modelAfterMutation(id, response, 'Failed to reject');
  }

  @override
  Future<AppointmentModel> updateStatus(String id, String status) async {
    final uri = Uri.parse('$_base${ApiConstants.garageAppointmentStatus(id)}');
    final encoded = jsonEncode({'status': status});
    final response = await _patchThenPut(uri, body: encoded);
    return _modelAfterMutation(id, response, 'Failed to update status');
  }
}
