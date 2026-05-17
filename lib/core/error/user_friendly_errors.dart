import '../../l10n/app_localizations.dart';

/// Converts raw error messages (from API, exceptions, or failures) into
/// user-friendly text shown in SnackBars and error screens.
String toUserFriendlyMessage(String message, AppLocalizations l10n) {
  if (message.trim().isEmpty) {
    return l10n.errorGeneric;
  }
  final lower = message.toLowerCase();

  // Server / 5xx
  if (lower.contains('server error') ||
      lower.contains('internal server') ||
      lower.contains('500') ||
      lower.contains('502') ||
      lower.contains('503') ||
      lower == 'server error') {
    return l10n.errorGeneric;
  }

  // Auth
  if (lower.contains('not authenticated') ||
      lower.contains('unauthorized') ||
      lower.contains('401') ||
      lower.contains('token') && lower.contains('invalid')) {
    return l10n.errorSignInAgain;
  }
  if (lower.contains('verify your email otp')) {
    return l10n.verifyOtpBeforeContinue;
  }
  if (lower.contains('invalid credentials') ||
      lower.contains('wrong password') ||
      lower.contains('invalid email')) {
    return l10n.errorInvalidCredentials;
  }
  if (lower.contains('forbidden') || lower.contains('403')) {
    return l10n.errorForbidden;
  }
  if (lower.contains('not found') || lower.contains('404')) {
    return l10n.errorNotFound;
  }

  // Network
  if (lower.contains('socket') ||
      lower.contains('connection') ||
      lower.contains('network') ||
      lower.contains('timeout') ||
      lower.contains('connection refused')) {
    return l10n.errorConnection;
  }

  // App reached a web page instead of the JSON API (wrong base URL or server down).
  if (lower.contains('html page instead of json') ||
      lower.contains('error page instead of json') ||
      lower.contains('api_base_url')) {
    return l10n.errorApiUnreachable;
  }

  // Generic exception prefixes to strip
  final withoutPrefix = message
      .replaceFirst(RegExp(r'^Exception:\s*', caseSensitive: false), '')
      .replaceFirst(RegExp(r'^ServerException:\s*', caseSensitive: false), '')
      .replaceFirst(RegExp(r'^NetworkException:\s*', caseSensitive: false), '')
      .trim();

  if (withoutPrefix.isEmpty) return l10n.errorGeneric;
  return withoutPrefix;
}
