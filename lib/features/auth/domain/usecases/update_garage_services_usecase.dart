import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case: update garage services only (calls PATCH /garages/me/services/:garageId).
class UpdateGarageServicesUseCase {
  UpdateGarageServicesUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call(
    String garageId,
    List<String> serviceSlugs,
    String? otherServices,
  ) =>
      _repository.updateGarageServices(garageId, serviceSlugs, otherServices);
}
