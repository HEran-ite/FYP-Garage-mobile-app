/// Base exception class for data layer
abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  /// So `catch (e) => e.toString()` shows the real message (not
  /// `Instance of 'ServerException'`).
  @override
  String toString() => message;
}

/// Server exception
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Session no longer valid (HTTP 401/403). Still a [ServerException] for shared handling.
class UnauthorizedException extends ServerException {
  const UnauthorizedException([super.message = 'Please sign in again.']);
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Cache exception
class CacheException extends AppException {
  const CacheException(super.message);
}

