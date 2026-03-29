import 'dart:convert';

/// Reads JWT `exp` without verifying the signature (same as typical client expiry checks).
/// Returns [null] if the token is not a decodable JWT (e.g. opaque token) — caller must
/// rely on the server returning 401/403.
class JwtExpiry {
  JwtExpiry._();

  /// `true` = past expiry, `false` = not yet expired, `null` = cannot tell from token.
  static bool? isExpired(String token) {
    final exp = readExpUtc(token);
    if (exp == null) return null;
    return DateTime.now().toUtc().isAfter(exp);
  }

  static DateTime? readExpUtc(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
      }
      if (exp is num) {
        return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
