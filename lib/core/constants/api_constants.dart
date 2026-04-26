/// API endpoint and configuration constants
class ApiConstants {
  ApiConstants._();

  /// Fallback when API_BASE_URL is not set in .env (e.g. production URL)
  static const String baseUrl = 'https://driver-garage-backend.onrender.com';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Garage auth paths (relative to base URL)
  static const String garageAuthLogin = '/garages/auth/login';
  static const String garageAuthSignup = '/garages/auth/signup';

  /// Garage profile (backend garage-missing-endpoints: GET/PUT /garage/profile)
  static const String garageProfile = '/garage/profile';
  static const String garageChangePassword = '/garage/profile/change-password';

  /// Garage services (backend: GET/PUT/POST /garages/me/services, PATCH/DELETE /garages/me/services/:id)
  static const String garageMeServicesList = '/garages/me/services';
  static String garageMeServiceById(String serviceId) => '/garages/me/services/$serviceId';

  /// Garage appointments (JWT). Matches driver-garage-backend garage-missing-endpoints:
  /// GET/PATCH `/garages/appointments`, PATCH `.../:id/approve`, `.../:id/reject`, `.../:id/status`.
  static const String garageAppointments = '/garages/appointments';
  static String garageAppointmentById(String id) => '/garages/appointments/$id';
  static String garageAppointmentApprove(String id) =>
      '/garages/appointments/$id/approve';
  static String garageAppointmentReject(String id) =>
      '/garages/appointments/$id/reject';
  static String garageAppointmentStatus(String id) =>
      '/garages/appointments/$id/status';

  /// Garage availability (require JWT). Base path: /garages/availability
  static const String garageAvailabilityMeSlots =
      '/garages/availability/me/slots';
  static String garageAvailabilityMeSlotById(String id) =>
      '/garages/availability/me/slots/$id';

  /// Garage notifications (backend: GET /garages/notifications)
  static const String garageNotifications = '/garages/notifications';
  static String garageNotificationReadById(String id) =>
      '/garages/notifications/$id/read';
  static const String garageNotificationsReadAll =
      '/garages/notifications/read-all';

  /// Garage ratings/reviews
  /// Driver-facing: GET /garages/ratings/:garageId/reviews
  /// Garage-facing: GET /garages/ratings/reviews/me
  static const String garageRatingsReviewsMe = '/garages/ratings/reviews/me';
  static String garageRatingsReviewsByGarageId(String garageId) =>
      '/garages/ratings/$garageId/reviews';

  /// Garage settings (backend: GET/PUT /garages/settings)
  static const String garageSettings = '/garages/settings';
}
