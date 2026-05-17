import '../../l10n/app_localizations.dart';
import '../constants/auth_constants.dart';

/// Localized display label for a predefined or custom service name.
String localizedServiceLabel(AppLocalizations l10n, String label) {
  switch (label) {
    case 'Oil Change':
      return l10n.serviceOilChange;
    case 'Tire Service':
      return l10n.serviceTireService;
    case 'Brake Repair':
      return l10n.serviceBrakeRepair;
    case 'Engine Diagnostics':
      return l10n.serviceEngineDiagnostics;
    case 'Battery Service':
      return l10n.serviceBatteryService;
    case 'AC Repair':
      return l10n.serviceAcRepair;
    case 'Other':
      return l10n.serviceOther;
    default:
      return label;
  }
}

/// English label from backend slug (for API); falls back to slug.
String serviceLabelFromSlug(String slug) {
  return AuthConstants.serviceSlugToLabel[slug] ?? slug;
}

/// Localized label from backend slug.
String localizedServiceFromSlug(AppLocalizations l10n, String slug) {
  return localizedServiceLabel(l10n, serviceLabelFromSlug(slug));
}
