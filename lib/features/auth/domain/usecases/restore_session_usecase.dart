import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Loads stored session (token + user) from SharedPreferences. Returns user if present; caller should emit AuthLoginSuccess.
class RestoreSessionUseCase {
  RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity?> call() => _repository.loadSession();
}
