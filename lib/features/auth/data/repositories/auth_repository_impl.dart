import 'dart:typed_data';

import 'package:dartz/dartz.dart';

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
        await _sessionStorage.save(token, user);
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
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user) async {
    try {
      final model = user is UserModel ? user : UserModel(
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
      );
      final updated = await _remoteDataSource.updateProfile(model);
      final token = _remoteDataSource.authToken;
      if (token != null && token.isNotEmpty) {
        await _sessionStorage.save(token, updated);
      }
      return Right(updated);
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
    _remoteDataSource.setAuthToken(session.token);
    return session.user;
  }

  @override
  Future<void> clearSession() async {
    await _sessionStorage.clear();
    _remoteDataSource.clearAuthToken();
  }
}
