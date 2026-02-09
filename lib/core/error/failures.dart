/// Base failure class for domain layer
abstract class Failure {
  final String message;

  const Failure(this.message);
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

