import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/registration_entity.dart';
import '../entities/user_entity.dart';

/// Abstract auth repository - login and registration
abstract class AuthRepository {
  /// Sign in with email and password (backend: POST /garages/auth/login)
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Submit full registration (after step 3).
  /// [licenseBytes] + [licenseFileName] preferred for upload (path can be null on iOS/Android).
  Future<Either<Failure, UserEntity>> register(
    RegistrationEntity registration, {
    Uint8List? licenseBytes,
    String? licenseFileName,
  });

  /// Get current user if authenticated
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Update current garage profile (backend: PATCH /garages/me).
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user);

  /// Load stored session (token + user). Returns user if present and sets token. Used on app start.
  Future<UserEntity?> loadSession();

  /// Clear stored session and in-memory token. Used on logout.
  Future<void> clearSession();
}
