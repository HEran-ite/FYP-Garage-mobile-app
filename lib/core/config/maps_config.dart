import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Google Maps / Places API configuration.
///
/// The API key is read from the .env file (see .env.example).
/// Fallback: --dart-define=GOOGLE_MAPS_API_KEY=your_key
/// For production: enable Places API, Maps SDK for Android, Maps SDK for iOS
/// in Google Cloud Console and restrict the key.
String get kGoogleMapsApiKey =>
    dotenv.env['GOOGLE_MAPS_API_KEY'] ??
    const String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
