import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/api_constants.dart';

/// Backend API base URL from .env (API_BASE_URL) or fallback.
///
/// On Android emulator, `localhost` in .env is rewritten to `10.0.2.2` so the
/// app can reach a backend running on your development machine.
String get kApiBaseUrl {
  final fromEnv = dotenv.env['API_BASE_URL']?.trim();
  var url = (fromEnv != null && fromEnv.isNotEmpty)
      ? fromEnv
      : ApiConstants.baseUrl;
  if (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }
  return _resolveLocalhostForPlatform(url);
}

String _resolveLocalhostForPlatform(String url) {
  if (kIsWeb) return url;
  if (defaultTargetPlatform != TargetPlatform.android) return url;

  final uri = Uri.tryParse(url);
  if (uri == null) return url;
  final host = uri.host.toLowerCase();
  if (host != 'localhost' && host != '127.0.0.1') return url;

  return uri.replace(host: '10.0.2.2').toString();
}
