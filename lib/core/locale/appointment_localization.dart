import '../../l10n/app_localizations.dart';

/// Localized appointment status label for UI.
String localizedAppointmentStatus(AppLocalizations l10n, String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return l10n.statusPending;
    case 'APPROVED':
      return l10n.statusApprovedAppt;
    case 'IN_SERVICE':
    case 'IN_PROGRESS':
      return l10n.statusInProgress;
    case 'COMPLETED':
      return l10n.statusCompleted;
    case 'REJECTED':
      return l10n.statusRejected;
    case 'CANCELLED':
      return l10n.statusCancelled;
    default:
      return status;
  }
}

/// Localized garage account status for dashboard.
({String label}) localizedGarageStatus(AppLocalizations l10n, String? status) {
  switch (status?.toUpperCase()) {
    case 'ACTIVE':
      return (label: l10n.statusApproved);
    case 'PENDING':
      return (label: l10n.statusPendingApproval);
    case 'REJECTED':
      return (label: l10n.statusRejected);
    case 'BLOCKED':
      return (label: l10n.statusBlocked);
    case 'WARNED':
      return (label: l10n.statusWarned);
    default:
      return (label: l10n.statusPendingApproval);
  }
}
