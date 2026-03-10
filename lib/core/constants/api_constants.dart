/// API endpoint and configuration constants
class ApiConstants {
  ApiConstants._();

  /// Fallback when API_BASE_URL is not set in .env (e.g. production URL)
  static const String baseUrl = 'http://localhost:4000';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Garage auth paths (relative to base URL)
  static const String garageAuthLogin = '/garages/auth/login';
  static const String garageAuthSignup = '/garages/auth/signup';
}

