import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/registration_entity.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case: submit garage owner registration
class RegisterUseCase {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call(
    RegistrationEntity registration, {
    Uint8List? licenseBytes,
    String? licenseFileName,
  }) =>
      _repository.register(
        registration,
        licenseBytes: licenseBytes,
        licenseFileName: licenseFileName,
      );
}
