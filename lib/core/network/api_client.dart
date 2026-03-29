/// Placeholder for a shared HTTP client (e.g. Dio).
///
/// This app currently uses `package:http` per feature. For a central client, mirror
/// [reportUnauthorizedHttpStatus] from `core/auth/session_invalidation.dart` on 401/403
/// responses (same as server-side session expiry handling).
