import 'dart:typed_data';

import 'package:equatable/equatable.dart';

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
