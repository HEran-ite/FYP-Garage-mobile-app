import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

/// Step 1 form data (basic info)
class RegistrationStep1Data extends Equatable {
  const RegistrationStep1Data({
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

/// Step 2 form data (location & services)
class RegistrationStep2Data extends Equatable {
  const RegistrationStep2Data({
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

/// Auth BLoC states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial (login screen)
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Checking saved session (SharedPreferences) on app start. Show loading, not login form.
class AuthRestoringSession extends AuthState {
  const AuthRestoringSession();
}

/// Login in progress
class AuthLoginLoading extends AuthState {
  const AuthLoginLoading();
}

/// Login succeeded
class AuthLoginSuccess extends AuthState {
  const AuthLoginSuccess(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// Login failed
class AuthLoginError extends AuthState {
  const AuthLoginError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Registration step 1 (basic info)
class AuthRegistrationStep1 extends AuthState {
  const AuthRegistrationStep1();
}

/// Registration step 2 (location & services), with step 1 data
class AuthRegistrationStep2 extends AuthState {
  const AuthRegistrationStep2(this.step1Data);

  final RegistrationStep1Data step1Data;

  @override
  List<Object?> get props => [step1Data];
}

/// Registration step 3 (verification), with step 1 and 2 data
class AuthRegistrationStep3 extends AuthState {
  const AuthRegistrationStep3(this.step1Data, this.step2Data);

  final RegistrationStep1Data step1Data;
  final RegistrationStep2Data step2Data;

  @override
  List<Object?> get props => [step1Data, step2Data];
}

/// Registration submit in progress
class AuthRegistrationSubmitting extends AuthState {
  const AuthRegistrationSubmitting();
}

/// Registration submitted successfully (show modal)
class AuthRegistrationSuccess extends AuthState {
  const AuthRegistrationSuccess(this.user, this.garageName);

  final UserEntity user;
  final String garageName;

  @override
  List<Object?> get props => [user, garageName];
}

/// Registration failed. Optional [step1Data] and [step2Data] keep user on step 3 to retry.
class AuthRegistrationError extends AuthState {
  const AuthRegistrationError(
    this.message, {
    this.step1Data,
    this.step2Data,
  });

  final String message;
  final RegistrationStep1Data? step1Data;
  final RegistrationStep2Data? step2Data;

  @override
  List<Object?> get props => [message, step1Data, step2Data];
}

/// Profile update in progress (keeps [user] so UI can still show form).
class AuthProfileUpdating extends AuthState {
  const AuthProfileUpdating(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// Profile update failed. [user] is kept so app stays logged in with last known data.
class AuthProfileUpdateError extends AuthState {
  const AuthProfileUpdateError(this.message, this.user);

  final String message;
  final UserEntity user;

  @override
  List<Object?> get props => [message, user];
}
