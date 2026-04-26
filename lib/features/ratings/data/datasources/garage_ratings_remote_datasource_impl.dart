import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/auth/session_invalidation.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/data/datasources/auth_remote_datasource_impl.dart';
import '../models/garage_reviews_response_model.dart';
import 'garage_ratings_remote_datasource.dart';

class GarageRatingsRemoteDataSourceImpl implements GarageRatingsRemoteDataSource {
  GarageRatingsRemoteDataSourceImpl({http.Client? client})
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
  Future<GarageReviewsResponseModel> getMyReviews() async {
    final uri = Uri.parse('$_base${ApiConstants.garageRatingsReviewsMe}');
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(ApiConstants.connectionTimeout);
    final decoded = _parseJson(response.body);
    if (response.statusCode != 200) {
      reportUnauthorizedHttpStatus(response.statusCode);
      final body = decoded is Map ? decoded as Map<String, dynamic> : <String, dynamic>{};
      throw ServerException(body['error']?.toString() ?? 'Failed to load reviews');
    }
    if (decoded is! Map) throw const ServerException('Invalid reviews response');
    return GarageReviewsResponseModel.fromJson(Map<String, dynamic>.from(decoded));
  }
}
