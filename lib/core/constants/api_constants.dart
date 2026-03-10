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

  /// Garage availability (me) paths
  static const String garageAvailabilityMeSlots = '/garages/me/availability/slots';
  static String garageAvailabilityMeSlotById(String id) =>
      '/garages/me/availability/slots/$id';

  /// Garage appointments (me) paths
  static const String garageAppointments = '/garages/me/appointments';
  static String garageAppointmentById(String id) =>
      '/garages/me/appointments/$id';
  static String garageAppointmentApprove(String id) =>
      '/garages/me/appointments/$id/approve';
  static String garageAppointmentReject(String id) =>
      '/garages/me/appointments/$id/reject';
  static String garageAppointmentStatus(String id) =>
      '/garages/me/appointments/$id/status';
}

