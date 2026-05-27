import 'package:flutter/foundation.dart';

/// Stable keys for integration and widget tests.
class TestKeys {
  TestKeys._();

  // Onboarding
  static const onboardingSkip = Key('onboarding_skip');
  static const onboardingContinue = Key('onboarding_continue');

  // Auth
  static const loginEmail = Key('login_email');
  static const loginPassword = Key('login_password');
  static const loginSubmit = Key('login_submit');
  static const loginCreateAccountLink = Key('login_create_account_link');

  // Bottom navigation
  static const navDashboard = Key('nav_dashboard');
  static const navAppointments = Key('nav_appointments');
  static const navServices = Key('nav_services');
  static const navProfile = Key('nav_profile');

  // Dashboard
  static const notificationsButton = Key('notifications_button');

  // Appointments
  static const appointmentSearch = Key('appointment_search');
  static const appointmentFilterAll = Key('appointment_filter_all');
  static const appointmentFilterPending = Key('appointment_filter_pending');
  static const appointmentFilterApproved = Key('appointment_filter_approved');
  static const appointmentFilterInProgress = Key('appointment_filter_in_progress');
  static const appointmentFilterCompleted = Key('appointment_filter_completed');
  static const appointmentFilterRejected = Key('appointment_filter_rejected');

  // Services
  static const servicesSave = Key('services_save');

  // Profile
  static const profileAvailabilityEdit = Key('profile_availability_edit');
  static const profileLogout = Key('profile_logout');
}
