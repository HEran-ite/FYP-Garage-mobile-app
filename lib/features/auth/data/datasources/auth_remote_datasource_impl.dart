import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../../core/auth/session_invalidation.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/auth_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/garage_service_item.dart';
import '../models/registration_model.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// In-memory token storage (set on login). Replace with secure storage for production.
String? _authToken;

String? get authToken => _authToken;
void setAuthToken(String? token) => _authToken = token;

/// Real implementation calling driver-garage-backend (branch Garage-profile-Yordi).
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  String get _base => kApiBaseUrl;

  void _throwUnauthorizedIfNeeded(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      reportUnauthorizedHttpStatus(statusCode);
      throw const UnauthorizedException();
    }
  }

  @override
  String? get authToken => _authToken;

  @override
  void setAuthToken(String? token) {
    _authToken = token;
  }

  @override
  void clearAuthToken() {
    _authToken = null;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_base${ApiConstants.garageAuthLogin}');
    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(ApiConstants.connectionTimeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      if (response.statusCode == 200) {
        final token = body['token'] as String?;
        if (token != null) setAuthToken(token);
        final garage = body['garage'] as Map<String, dynamic>?;
        if (garage != null) return UserModel.fromGarageJson(garage);
        return UserModel.fromGarageJson(body);
      }
      final err = body['error'] as String? ?? 'Invalid credentials';
      throw ServerException(err);
    } on ServerException {
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  @override
  Future<UserModel> register(
    RegistrationModel registration, {
    Uint8List? licenseBytes,
    String? licenseFileName,
  }) async {
    final uri = Uri.parse('$_base${ApiConstants.garageAuthSignup}');
    final path = registration.businessLicensePath;
    final hasBytes = licenseBytes != null && licenseBytes.isNotEmpty;
    final hasPath = path != null && path.isNotEmpty;
    if (!hasBytes && !hasPath) {
      throw const ServerException(
        'Business license document is required (PDF, JPG or PNG, max 10MB).',
      );
    }

    final request = http.MultipartRequest('POST', uri);
    request.fields['garage_name'] = registration.garageName;
    request.fields['phone_number'] = registration.phone;
    request.fields['email'] = registration.email;
    request.fields['password'] = registration.password;
    request.fields['confirm_password'] = registration.confirmPassword;
    // Round to 6 decimal places so backend/Prisma (e.g. Decimal) accept the values
    final lat = registration.latitude != null
        ? (registration.latitude! * 1e6).round() / 1e6
        : 0.0;
    final lng = registration.longitude != null
        ? (registration.longitude! * 1e6).round() / 1e6
        : 0.0;
    request.fields['garage_location'] = jsonEncode({
      'address': registration.address,
      'latitude': lat,
      'longitude': lng,
      'place_id': registration.placeId ?? '',
    });
    // Same merge as Services tab / updateGarageServices: one list of offerings.
    final orderedNames = <String>[];
    final seen = <String>{};
    void addName(String raw) {
      final t = raw.trim();
      if (t.isEmpty || seen.contains(t)) return;
      seen.add(t);
      orderedNames.add(t);
    }

    for (final s in registration.services) {
      addName(s);
    }
    if (registration.otherServices != null &&
        registration.otherServices!.trim().isNotEmpty) {
      for (final part
          in registration.otherServices!.split(RegExp(r',\s*'))) {
        addName(part);
      }
    }

    final slugs = orderedNames
        .map(
          (name) =>
              AuthConstants.serviceLabelToSlug[name] ??
              name.toLowerCase().replaceAll(RegExp(r'\s+'), '_'),
        )
        .toList();

    final customNames = orderedNames
        .where((n) => !AuthConstants.serviceOptionsPredefined.contains(n))
        .toList();
    if (customNames.isNotEmpty) {
      request.fields['other_services'] = customNames.join(', ');
    }
    request.fields['services_offered'] = jsonEncode(slugs);

    final String filename =
        licenseFileName ??
        (path != null ? path.split(RegExp(r'[/\\]')).last : 'document');
    final MediaType? contentType = _contentTypeFromFilename(filename);
    if (hasBytes) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'business_license_document',
          licenseBytes,
          filename: filename,
          contentType: contentType,
        ),
      );
    } else {
      try {
        final file = File(path!);
        if (!await file.exists())
          throw ServerException('File not found: $path');
        final bytes = await file.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'business_license_document',
            bytes,
            filename: filename,
            contentType: contentType,
          ),
        );
      } catch (e) {
        throw ServerException('Could not read license file: $e');
      }
    }

    try {
      final streamed = await request.send().timeout(
        ApiConstants.connectionTimeout,
      );
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};

      if (response.statusCode == 201) {
        return UserModel.fromSignupJson(body);
      }
      final err =
          body['error'] as String? ??
          body['errors']?.toString() ??
          'Signup failed';
      throw ServerException(err);
    } on ServerException {
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = authToken;
    if (token == null || token.isEmpty) return null;
    try {
      return await getProfile();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel> getProfile() async {
    final uri = Uri.parse('$_base${ApiConstants.garageProfile}');
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
    final body = _parseJsonResponse(response.body);
    if (response.statusCode == 200) {
      return UserModel.fromGarageJson(body);
    }
    _throwUnauthorizedIfNeeded(response.statusCode);
    final err =
        body['error'] as String? ??
        body['errors']?.toString() ??
        'Failed to load profile';
    throw ServerException(err);
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    final uri = Uri.parse('$_base${ApiConstants.garageProfile}');
    final token = authToken;
    if (token == null || token.isEmpty) {
      throw const ServerException('Not authenticated');
    }
    // Backend PUT /garage/profile: name, email, phone, and garage_location (same shape as signup/GET).
    final body = <String, dynamic>{
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
    };
    if (user.address != null ||
        user.latitude != null ||
        user.longitude != null ||
        user.placeId != null) {
      final lat = user.latitude != null
          ? (user.latitude! * 1e6).round() / 1e6
          : null;
      final lng = user.longitude != null
          ? (user.longitude! * 1e6).round() / 1e6
          : null;
      body['garage_location'] = {
        'address': user.address ?? '',
        if (lat != null) 'latitude': lat,
        if (lng != null) 'longitude': lng,
        'place_id': user.placeId ?? '',
      };
      if (user.address != null) body['address'] = user.address;
      if (lat != null) body['latitude'] = lat;
      if (lng != null) body['longitude'] = lng;
      if (user.placeId != null) body['place_id'] = user.placeId;
    }
    try {
      final response = await _client
          .put(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.connectionTimeout);

      final responseBody = _parseJsonResponse(response.body);
      if (response.statusCode == 200) {
        return UserModel.fromGarageJson(responseBody);
      }
      _throwUnauthorizedIfNeeded(response.statusCode);
      final err =
          responseBody['error'] as String? ??
          responseBody['errors']?.toString() ??
          'Profile update failed';
      throw ServerException(err);
    } on ServerException {
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  @override
  Future<List<GarageServiceItem>> listGarageServices() async {
    final uri = Uri.parse('$_base${ApiConstants.garageMeServicesList}');
    final token = authToken;
    if (token == null || token.isEmpty) {
      throw const ServerException('Not authenticated');
    }
    try {
      final response = await _client
          .get(
            uri,
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(ApiConstants.connectionTimeout);
      if (response.statusCode != 200) {
        _throwUnauthorizedIfNeeded(response.statusCode);
        final body = _parseJsonResponse(response.body);
        final err =
            body['error'] as String? ??
            body['errors']?.toString() ??
            'Failed to list services';
        throw ServerException(err);
      }
      final decoded = jsonDecode(response.body);
      final list = decoded is List
          ? List<dynamic>.from(decoded)
          : (decoded is Map
              ? (decoded['services'] as List? ?? decoded['data'] as List? ?? [])
              : <dynamic>[]);
      return list
          .map((e) => GarageServiceItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  @override
  Future<GarageServiceItem> createGarageService(String name) async {
    final uri = Uri.parse('$_base${ApiConstants.garageMeServicesList}');
    final token = authToken;
    if (token == null || token.isEmpty) {
      throw const ServerException('Not authenticated');
    }
    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'name': name.trim()}),
          )
          .timeout(ApiConstants.connectionTimeout);
      final body = _parseJsonResponse(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final map = body.isNotEmpty ? body : (body['service'] as Map<String, dynamic>? ?? {});
        if (map.isEmpty) throw ServerException('Invalid create service response');
        return GarageServiceItem.fromJson(Map<String, dynamic>.from(map));
      }
      _throwUnauthorizedIfNeeded(response.statusCode);
      final err =
          body['error'] as String? ??
          body['errors']?.toString() ??
          'Failed to create service';
      throw ServerException(err);
    } on ServerException {
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  @override
  Future<void> deleteGarageService(String serviceId) async {
    final uri = Uri.parse('$_base${ApiConstants.garageMeServiceById(serviceId)}');
    final token = authToken;
    if (token == null || token.isEmpty) {
      throw const ServerException('Not authenticated');
    }
    try {
      final response = await _client
          .delete(
            uri,
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(ApiConstants.connectionTimeout);
      if (response.statusCode == 204 || response.statusCode == 200) return;
      _throwUnauthorizedIfNeeded(response.statusCode);
      final body = _parseJsonResponse(response.body);
      final err =
          body['error'] as String? ??
          body['errors']?.toString() ??
          'Failed to delete service';
      throw ServerException(err);
    } on ServerException {
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  @override
  Future<void> replaceGarageServices(List<String> services) async {
    final uri = Uri.parse('$_base${ApiConstants.garageMeServicesList}');
    final token = authToken;
    if (token == null || token.isEmpty) {
      throw const ServerException('Not authenticated');
    }
    final body = <String, dynamic>{
      'services': services,
    };
    try {
      final response = await _client
          .put(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.connectionTimeout);
      if (response.statusCode != 200) {
        _throwUnauthorizedIfNeeded(response.statusCode);
        final parsed = _parseJsonResponse(response.body);
        final err =
            parsed['error'] as String? ??
            parsed['errors']?.toString() ??
            'Failed to update services';
        throw ServerException(err);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  /// Parses response body as JSON. Throws [ServerException] if body is HTML or invalid JSON.
  static Map<String, dynamic> _parseJsonResponse(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return {};
    if (trimmed.toLowerCase().startsWith('<!')) {
      throw ServerException(
        'Server returned an error page instead of JSON. '
        'Check that the API base URL is correct and the backend is running (e.g. PUT /garage/profile or PUT /garages/me/services).',
      );
    }
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } on FormatException catch (e) {
      throw ServerException(
        'Invalid server response: ${e.message}. '
        'The server may have returned an error page—check the API URL and backend.',
      );
    }
  }

  /// Backend expects application/pdf, image/jpeg, image/jpg, image/png.
  static MediaType? _contentTypeFromFilename(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      default:
        return null;
    }
  }
}
