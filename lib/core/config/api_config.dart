import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/api_constants.dart';

/// Backend API base URL from .env (API_BASE_URL) or fallback.
/// For local backend: http://localhost:4000 (no trailing slash).
String get kApiBaseUrl {
  final fromEnv = dotenv.env['API_BASE_URL']?.trim();
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return fromEnv.endsWith('/') ? fromEnv.substring(0, fromEnv.length - 1) : fromEnv;
  }
  return ApiConstants.baseUrl;
}
