/// Route path constants
class RoutePaths {
  RoutePaths._();

  // Auth
  static const String login = '/login';
  static const String createAccount = '/create-account';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Appointments
  static const String appointments = '/appointments';
  static const String appointmentDetail = '/appointments/:id';
  static const String bookAppointment = '/appointments/book';

  // Services
  static const String services = '/services';
  static const String serviceDetail = '/services/:id';
  static const String createService = '/services/create';

  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  // Notifications
  static const String notifications = '/notifications';
}

