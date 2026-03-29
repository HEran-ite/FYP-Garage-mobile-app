import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/auth/jwt_expiry.dart';
import '../../../../core/constants/auth_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/registration_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_session_storage.dart';
import '../models/registration_model.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepository]
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._sessionStorage);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthSessionStorage _sessionStorage;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      final token = _remoteDataSource.authToken;
      if (token != null && token.isNotEmpty) {
        UserModel toSave = user;
        try {
          toSave = await _remoteDataSource.getProfile();
        } catch (_) {
          // Keep login response user if getProfile fails
        }
        await _sessionStorage.save(token, toSave);
        return Right(toSave);
      }
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
    RegistrationEntity registration, {
    Uint8List? licenseBytes,
    String? licenseFileName,
  }) async {
    try {
      final model = RegistrationModel.fromEntity(registration);
      final user = await _remoteDataSource.register(
        model,
        licenseBytes: licenseBytes,
        licenseFileName: licenseFileName,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final session = await _sessionStorage.load();
      if (session == null) {
        _remoteDataSource.clearAuthToken();
        return const Right(null);
      }
      if (JwtExpiry.isExpired(session.token) == true) {
        await clearSession();
        return const Right(null);
      }
      _remoteDataSource.setAuthToken(session.token);
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } on UnauthorizedException {
      await clearSession();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user) async {
    try {
      final model = user is UserModel
          ? user
          : UserModel(
              id: user.id,
              name: user.name,
              email: user.email,
              phone: user.phone,
              address: user.address,
              latitude: user.latitude,
              longitude: user.longitude,
              placeId: user.placeId,
              services: user.services,
              otherServices: user.otherServices,
              garageStatus: user.garageStatus,
            );
      final updated = await _remoteDataSource.updateProfile(model);
      // Backend PUT /garage/profile returns only name, email, phone, services; preserve address/location from current user.
      final merged = UserModel(
        id: updated.id,
        name: updated.name,
        email: updated.email,
        phone: updated.phone,
        address: updated.address ?? model.address,
        latitude: updated.latitude ?? model.latitude,
        longitude: updated.longitude ?? model.longitude,
        placeId: updated.placeId ?? model.placeId,
        services: updated.services,
        otherServices: updated.otherServices,
        garageStatus: updated.garageStatus,
      );
      final token = _remoteDataSource.authToken;
      if (token != null && token.isNotEmpty) {
        await _sessionStorage.save(token, merged);
      }
      return Right(merged);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateGarageServices(
    String garageId,
    List<String> serviceSlugs,
    String? otherServices,
  ) async {
    try {
      final session = await _sessionStorage.load();
      if (session == null) {
        return Left(ServerFailure('Not authenticated'));
      }
      _remoteDataSource.setAuthToken(session.token);
      final currentUser = session.user;
      // Treat [serviceSlugs] as service names/labels; backend expects names.
      final names = <String>{
        ...serviceSlugs.map((s) => s.trim()).where((s) => s.isNotEmpty),
      };
      if (otherServices != null && otherServices.trim().isNotEmpty) {
        final custom = otherServices
            .split(RegExp(r',\s*'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty);
        names.addAll(custom);
      }
      await _remoteDataSource.replaceGarageServices(names.toList());

      final predefined = names
          .where((n) => AuthConstants.serviceOptionsPredefined.contains(n))
          .toList();
      final customNames = names
          .where((n) => !AuthConstants.serviceOptionsPredefined.contains(n))
          .toList();
      final otherServicesStr =
          customNames.isEmpty ? null : customNames.join(', ');

      final updatedUser = UserModel(
        id: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
        phone: currentUser.phone,
        address: currentUser.address,
        latitude: currentUser.latitude,
        longitude: currentUser.longitude,
        placeId: currentUser.placeId,
        services: predefined.isEmpty ? null : predefined,
        otherServices: otherServicesStr,
        garageStatus: currentUser.garageStatus,
      );
      await _sessionStorage.save(session.token, updatedUser);
      return Right(updatedUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<UserEntity?> loadSession() async {
    final session = await _sessionStorage.load();
    if (session == null) return null;
    if (JwtExpiry.isExpired(session.token) == true) {
      await clearSession();
      return null;
    }
    _remoteDataSource.setAuthToken(session.token);
    // Refetch profile so we have latest services when displaying
    try {
      final profile = await _remoteDataSource.getProfile();
      final merged = UserModel(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        phone: profile.phone,
        address: profile.address ?? session.user.address,
        latitude: profile.latitude ?? session.user.latitude,
        longitude: profile.longitude ?? session.user.longitude,
        placeId: profile.placeId ?? session.user.placeId,
        services: profile.services,
        otherServices: profile.otherServices,
        garageStatus: profile.garageStatus,
      );
      await _sessionStorage.save(session.token, merged);
      return merged;
    } on UnauthorizedException {
      await clearSession();
      return null;
    } catch (_) {
      return session.user;
    }
  }

  @override
  Future<void> clearSession() async {
    await _sessionStorage.clear();
    _remoteDataSource.clearAuthToken();
  }
}
