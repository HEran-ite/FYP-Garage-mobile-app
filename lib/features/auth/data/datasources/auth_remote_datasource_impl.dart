import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/auth_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/registration_model.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// In-memory token storage (set on login). Replace with secure storage for production.
String? _authToken;

String? get authToken => _authToken;
void setAuthToken(String? token) => _authToken = token;

/// Real implementation calling driver-garage-backend (branch Garage-profile-Yordi).
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String get _base => kApiBaseUrl;

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
    request.fields['services_offered'] = jsonEncode(
      registration.services
          .map((s) => AuthConstants.serviceLabelToSlug[s] ?? s.toLowerCase().replaceAll(' ', '_'))
          .toList(),
    );
    if (registration.otherServices != null && registration.otherServices!.isNotEmpty) {
      request.fields['other_services'] = registration.otherServices!;
    }

    final String filename = licenseFileName ??
        (path != null ? path.split(RegExp(r'[/\\]')).last : 'document');
    final MediaType? contentType = _contentTypeFromFilename(filename);
    if (hasBytes) {
      request.files.add(http.MultipartFile.fromBytes(
        'business_license_document',
        licenseBytes,
        filename: filename,
        contentType: contentType,
      ));
    } else {
      try {
        final file = File(path!);
        if (!await file.exists()) throw ServerException('File not found: $path');
        final bytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'business_license_document',
          bytes,
          filename: filename,
          contentType: contentType,
        ));
      } catch (e) {
        throw ServerException('Could not read license file: $e');
      }
    }

    try {
      final streamed = await request.send().timeout(ApiConstants.connectionTimeout);
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};

      if (response.statusCode == 201) {
        return UserModel.fromSignupJson(body);
      }
      final err = body['error'] as String? ?? body['errors']?.toString() ?? 'Signup failed';
      throw ServerException(err);
    } on ServerException {
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async => null;

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
