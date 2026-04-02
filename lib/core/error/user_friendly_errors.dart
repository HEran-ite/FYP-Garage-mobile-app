/// Converts raw error messages (from API, exceptions, or failures) into
/// user-friendly text shown in SnackBars and error screens.
String toUserFriendlyMessage(String message) {
  if (message.trim().isEmpty) {
    return 'Something went wrong. Please try again.';
  }
  final lower = message.toLowerCase();

  // Server / 5xx
  if (lower.contains('server error') ||
      lower.contains('internal server') ||
      lower.contains('500') ||
      lower.contains('502') ||
      lower.contains('503') ||
      lower == 'server error') {
    return 'Something went wrong. Please try again.';
  }

  // Auth
  if (lower.contains('not authenticated') ||
      lower.contains('unauthorized') ||
      lower.contains('401') ||
      lower.contains('token') && lower.contains('invalid')) {
    return 'Please sign in again.';
  }
  if (lower.contains('invalid credentials') ||
      lower.contains('wrong password') ||
      lower.contains('invalid email')) {
    return 'Invalid email or password. Please try again.';
  }
  if (lower.contains('forbidden') || lower.contains('403')) {
    return 'You don\'t have permission to do this.';
  }
  if (lower.contains('not found') || lower.contains('404')) {
    return 'The requested item was not found.';
  }

  // Network
  if (lower.contains('socket') ||
      lower.contains('connection') ||
      lower.contains('network') ||
      lower.contains('timeout') ||
      lower.contains('connection refused')) {
    return 'Connection problem. Check your internet and try again.';
  }

  // App reached a web page instead of the JSON API (wrong base URL or server down).
  if (lower.contains('html page instead of json') ||
      lower.contains('error page instead of json') ||
      lower.contains('api_base_url')) {
    return 'Cannot reach the garage server. Set API_BASE_URL in .env to your backend '
        '(Android emulator: http://10.0.2.2:4000) and ensure npm run dev is running.';
  }

  // Generic exception prefixes to strip
  final withoutPrefix = message
      .replaceFirst(RegExp(r'^Exception:\s*', caseSensitive: false), '')
      .replaceFirst(RegExp(r'^ServerException:\s*', caseSensitive: false), '')
      .replaceFirst(RegExp(r'^NetworkException:\s*', caseSensitive: false), '')
      .trim();

  if (withoutPrefix.isEmpty) return 'Something went wrong. Please try again.';
  return withoutPrefix;
}
