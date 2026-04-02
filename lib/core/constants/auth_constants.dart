/// Authentication and registration constants
class AuthConstants {
  AuthConstants._();

  /// Number of steps in the create account flow
  static const int registrationStepCount = 3;

  /// Step indices (0-based)
  static const int stepBasicInfo = 0;
  static const int stepLocationServices = 1;
  static const int stepVerification = 2;

  /// Field constraints (backend requires min 8 for password)
  static const int minPasswordLength = 8;
  static const int maxGarageNameLength = 100;
  /// Enough for +251 9XX XXX XXX with spaces; validation uses normalized length.
  static const int maxPhoneLength = 20;
  static const int maxEmailLength = 255;
  static const int maxAddressLength = 500;
  static const int maxOtherServicesLength = 500;

  /// Supported document upload formats (display string)
  static const String supportedDocumentFormats = 'PDF, PNG or JPG (Max 5MB)';

  /// Approval time message
  static const String expectedApprovalTime = '24-48 hours';

  /// Placeholders
  static const String phonePlaceholder = '+251 9XX XXX XXX, 2519…, or 09XXXXXXXX';

  /// Ethiopian mobile: `+251` + 9 digits (13 chars), `251` + 9 digits (12), or `09` + 8 digits (10).
  static const String phoneFormatHint =
      'Use +251 9XX XXX XXX (13 characters), 2519XXXXXXXX (12 digits), or 09XXXXXXXX (10 digits).';

  /// Strip spaces and dashes; keep leading `+`.
  static String normalizePhoneInput(String raw) {
    final t = raw.trim();
    if (t.startsWith('+')) {
      return '+${t.substring(1).replaceAll(RegExp(r'[\s\-]'), '')}';
    }
    return t.replaceAll(RegExp(r'[\s\-]'), '');
  }

  /// Returns `null` if valid, else error message.
  static String? validateEthiopianPhone(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Required';
    final n = normalizePhoneInput(raw);
    if (RegExp(r'^\+2519\d{8}$').hasMatch(n)) return null;
    if (RegExp(r'^2519\d{8}$').hasMatch(n)) return null;
    if (RegExp(r'^09\d{8}$').hasMatch(n)) return null;
    return phoneFormatHint;
  }

  /// Normalized international form for API (+2519XXXXXXXX).
  static String normalizePhoneForApi(String raw) {
    final n = normalizePhoneInput(raw);
    if (n.startsWith('+251')) return n;
    if (RegExp(r'^2519\d{8}$').hasMatch(n)) return '+$n';
    if (RegExp(r'^09\d{8}$').hasMatch(n)) return '+251${n.substring(1)}';
    return n;
  }
  static const String passwordPlaceholder = 'Enter your password';
  static const String confirmPasswordPlaceholder = 'Confirm your password';
  static const String otherServicesPlaceholder =
      'Please specify other services you offer...';
  static const String uploadDocumentLabel = 'Upload Document';

  /// Predefined service options (label only)
  static const List<String> serviceOptions = [
    'Oil Change',
    'Tire Service',
    'Brake Repair',
    'Engine Diagnostics',
    'Battery Service',
    'AC Repair',
    'Other',
  ];

  /// Predefined only (no "Other"); use for grid. Custom services are listed separately.
  static const List<String> serviceOptionsPredefined = [
    'Oil Change',
    'Tire Service',
    'Brake Repair',
    'Engine Diagnostics',
    'Battery Service',
    'AC Repair',
  ];

  /// Map placeholder label
  static const String mapPreviewLabel = 'Map Preview';

  /// Location / map picker
  static const String mapTapToSetHint = 'Tap to open map';
  static const String mapSetExactLocationHint =
      'Set your exact location on the map to continue';
  static const String mapConfirmLocationTitle = 'Use this location?';
  static const String mapConfirmButton = 'Confirm';
  static const String mapChangeLocationButton = 'Change location';
  static const String mapSelectLocationAppBarTitle = 'Select location';
  static const String mapDragOrTapHint =
      'Drag the marker or tap on the map to set your garage location.';
  static const String mapDriverVisibilityMessage =
      'Drivers will see your garage at this address.';
  static const String mapSetCarefullyMessage =
      'Please set the pin carefully.';
  static const String mapLoadingAddress = 'Loading address...';
  static const String mapAddressUnavailable = 'Address could not be loaded';
  static const String addressRequiredMessage = 'Address is required';
  static const String locationRequiredMessage =
      'Please set your exact location on the map';

  static const String otherServiceId = 'Other';

  /// Map UI service labels to backend API slugs (Garage-profile-Yordi)
  static const Map<String, String> serviceLabelToSlug = {
    'Oil Change': 'oil_change',
    'Tire Service': 'tire_service',
    'Brake Repair': 'brake_repair',
    'Engine Diagnostics': 'engine_diagnostics',
    'Battery Service': 'battery_service',
    'AC Repair': 'ac_repair',
    'Other': 'other',
  };

  /// Reverse map: backend slugs → UI labels (for loading from API).
  static const Map<String, String> serviceSlugToLabel = {
    'oil_change': 'Oil Change',
    'tire_service': 'Tire Service',
    'brake_repair': 'Brake Repair',
    'engine_diagnostics': 'Engine Diagnostics',
    'battery_service': 'Battery Service',
    'ac_repair': 'AC Repair',
    'other': 'Other',
  };
}
