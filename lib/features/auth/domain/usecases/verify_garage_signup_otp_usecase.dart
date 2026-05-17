import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyGarageSignupOtpUseCase {
  VerifyGarageSignupOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call({
    required String email,
    required String code,
  }) {
    return _repository.verifyGarageSignupOtp(email: email, code: code);
  }
}
