import '../repositories/auth_repository.dart';

/// Clears stored session (SharedPreferences + in-memory token). Used on logout.
class ClearSessionUseCase {
  ClearSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.clearSession();
}
