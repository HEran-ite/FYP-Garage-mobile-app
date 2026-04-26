import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

/// Auth BLoC events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Start registration flow (navigate to step 1)
class AuthRegistrationStarted extends AuthEvent {
  const AuthRegistrationStarted();
}

/// Request login with email and password (backend: POST /garages/auth/login)
class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Step 1 next: basic info submitted
class AuthRegistrationStep1Next extends AuthEvent {
  const AuthRegistrationStep1Next({
    required this.garageName,
    required this.phone,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  final String garageName;
  final String phone;
  final String email;
  final String password;
  final String confirmPassword;

  @override
  List<Object?> get props => [garageName, phone, email, password, confirmPassword];
}

/// Step 2 next: location and services submitted
class AuthRegistrationStep2Next extends AuthEvent {
  const AuthRegistrationStep2Next({
    required this.address,
    required this.services,
    this.otherServices,
    this.latitude,
    this.longitude,
    this.placeId,
  });

  final String address;
  final List<String> services;
  final String? otherServices;
  final double? latitude;
  final double? longitude;
  final String? placeId;

  @override
  List<Object?> get props => [address, services, otherServices, latitude, longitude, placeId];
}

/// Navigate back from step 2 to step 1
class AuthRegistrationStep2Back extends AuthEvent {
  const AuthRegistrationStep2Back();
}

/// Navigate back from step 3 to step 2
class AuthRegistrationStep3Back extends AuthEvent {
  const AuthRegistrationStep3Back();
}

/// Submit full registration (step 3).
/// Prefer [businessLicenseBytes] + [businessLicenseFileName] (works when path is null on iOS/Android).
class AuthRegistrationSubmitted extends AuthEvent {
  const AuthRegistrationSubmitted({
    this.businessLicensePath,
    this.businessLicenseBytes,
    this.businessLicenseFileName,
  });

  final String? businessLicensePath;
  final Uint8List? businessLicenseBytes;
  final String? businessLicenseFileName;

  @override
  List<Object?> get props => [businessLicensePath, businessLicenseBytes, businessLicenseFileName];
}

/// Dismiss registration success modal
class AuthRegistrationSuccessDismissed extends AuthEvent {
  const AuthRegistrationSuccessDismissed();
}

/// Cancel registration flow (e.g. back from step 1)
class AuthRegistrationCancelled extends AuthEvent {
  const AuthRegistrationCancelled();
}

/// Restore session from SharedPreferences on app start. If stored token + user exist, emit AuthLoginSuccess.
class AuthRestoreSession extends AuthEvent {
  const AuthRestoreSession();
}

/// Refresh profile/session silently without emitting loading state.
class AuthRefreshProfileRequested extends AuthEvent {
  const AuthRefreshProfileRequested();
}

/// Clear session after expired JWT, 401/403 from API, or explicit invalidation. Root listener navigates to login.
class AuthSessionInvalidated extends AuthEvent {
  const AuthSessionInvalidated();
}

/// Logout: clear stored session and in-memory token, then return to login
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Profile updated (name, phone, email, address). Uses PATCH /garages/me.
class AuthProfileUpdated extends AuthEvent {
  const AuthProfileUpdated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// Services updated only. Uses PATCH /garages/me/services/:garageId.
class AuthServicesUpdated extends AuthEvent {
  const AuthServicesUpdated({
    required this.garageId,
    required this.serviceLabels,
    this.otherServices,
  });

  final String garageId;
  final List<String> serviceLabels;
  final String? otherServices;

  @override
  List<Object?> get props => [garageId, serviceLabels, otherServices];
}
