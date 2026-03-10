import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case: update current garage profile (calls PATCH /garages/me).
class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call(UserEntity user) =>
      _repository.updateProfile(user);
}
