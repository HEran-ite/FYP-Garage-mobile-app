/// Notifies the app root to clear the session and show login (401/403 or expired JWT on resume).
final SessionInvalidationNotifier sessionInvalidationNotifier =
    SessionInvalidationNotifier();

class SessionInvalidationNotifier {
  /// Set from [GarageUpApp] / [_AuthSessionShell] to dispatch [AuthSessionInvalidated].
  void Function()? onSessionExpired;

  void notify() => onSessionExpired?.call();
}

/// Call when an HTTP response indicates the session is no longer valid.
void reportUnauthorizedHttpStatus(int statusCode) {
  if (statusCode != 401 && statusCode != 403) return;
  sessionInvalidationNotifier.notify();
}
