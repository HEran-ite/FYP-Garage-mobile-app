import '../../l10n/app_localizations.dart';

List<String> localizedMonthNames(AppLocalizations l10n) => [
      l10n.monthJan,
      l10n.monthFeb,
      l10n.monthMar,
      l10n.monthApr,
      l10n.monthMay,
      l10n.monthJun,
      l10n.monthJul,
      l10n.monthAug,
      l10n.monthSep,
      l10n.monthOct,
      l10n.monthNov,
      l10n.monthDec,
    ];

List<String> localizedWeekdayNames(AppLocalizations l10n) => [
      l10n.dayMonday,
      l10n.dayTuesday,
      l10n.dayWednesday,
      l10n.dayThursday,
      l10n.dayFriday,
      l10n.daySaturday,
      l10n.daySunday,
    ];

String formatRelativeTime(AppLocalizations l10n, DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inSeconds < 45) return l10n.justNow;
  if (diff.inMinutes < 2) return l10n.oneMinAgo;
  if (diff.inMinutes < 60) return l10n.minsAgo(diff.inMinutes);
  if (diff.inHours < 2) return l10n.oneHourAgo;
  if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
  if (diff.inDays == 1) return l10n.yesterday;
  if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
  final months = localizedMonthNames(l10n);
  return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
}

/// Localized appointment schedule string, e.g. "Feb 5, 10:00 AM".
String formatScheduledAtDisplay(AppLocalizations l10n, String scheduledAt) {
  if (scheduledAt.trim().isEmpty) return l10n.emDash;
  try {
    final dt = DateTime.parse(scheduledAt).toLocal();
    final months = localizedMonthNames(l10n);
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? l10n.pm : l10n.am;
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, $hour:$minute $period';
  } catch (_) {
    return scheduledAt;
  }
}
