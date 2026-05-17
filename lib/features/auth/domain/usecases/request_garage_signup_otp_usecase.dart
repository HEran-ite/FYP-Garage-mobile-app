import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class RequestGarageSignupOtpUseCase {
  RequestGarageSignupOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, int?>> call({required String email}) {
    return _repository.requestGarageSignupOtp(email: email);
  }
}
