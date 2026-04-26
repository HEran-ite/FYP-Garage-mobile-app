import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

String _timeAgo(DateTime? dateTime) {
  if (dateTime == null) return '';
  final diff = DateTime.now().difference(dateTime);
  if (diff.inSeconds < 45) return 'Just now';
  if (diff.inMinutes < 60) {
    final mins = diff.inMinutes;
    return mins == 1 ? '1 min ago' : '$mins mins ago';
  }
  if (diff.inHours < 24) {
    final hours = diff.inHours;
    return hours == 1 ? '1 hour ago' : '$hours hours ago';
  }
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  if (diff.inDays < 365) {
    final m = _monthShort(dateTime.month);
    return '$m ${dateTime.day}, ${_formatHourMinute(dateTime)}';
  }
  final m = _monthShort(dateTime.month);
  return '$m ${dateTime.day}, ${dateTime.year}';
}

String _monthShort(int month) {
  const names = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return (month >= 1 && month <= 12) ? names[month - 1] : '';
}

String _formatHourMinute(DateTime dateTime) {
  final hour24 = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final isPm = hour24 >= 12;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final period = isPm ? 'PM' : 'AM';
  return '$hour12:$minute $period';
}

String _sanitizeNotificationText(String input) {
  var text = input.trim();
  if (text.isEmpty) return text;

  // Remove long IDs (UUID-like or long mixed ids) from user-visible text.
  text = text.replaceAll(
    RegExp(
      r'\b[a-f0-9]{8}-[a-f0-9]{4}-[1-5][a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}\b',
      caseSensitive: false,
    ),
    '',
  );
  text = text.replaceAll(
    RegExp(
      r'\b(?:appointment|notification|service)\s*#?\s*[a-z0-9]{10,}\b',
      caseSensitive: false,
    ),
    '',
  );

  // Clean punctuation/spacing left after ID removal.
  text = text
      .replaceAll(RegExp(r'\s{2,}'), ' ')
      .replaceAll(RegExp(r'\s+([,.;:!?])'), r'$1')
      .replaceAll(RegExp(r'([,.;:!?]){2,}'), r'$1')
      .trim();

  return text;
}

DateTime? _extractIsoDateTime(String input) {
  final match = RegExp(
    r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z?',
  ).firstMatch(input);
  if (match == null) return null;
  final parsed = DateTime.tryParse(match.group(0)!);
  if (parsed == null) return null;
  return parsed.toLocal();
}

bool _isNewAppointmentText(NotificationEntity notification) {
  final haystack = '${notification.title} ${notification.body}'.toLowerCase();
  return haystack.contains('new appointment request') ||
      haystack.contains('requested an appointment');
}

String _friendlyNotificationTitle(NotificationEntity notification) {
  if (_isNewAppointmentText(notification)) {
    return 'New appointment request';
  }
  return _sanitizeNotificationText(notification.title);
}

String _friendlyNotificationBody(NotificationEntity notification) {
  if (_isNewAppointmentText(notification)) {
    final at = _extractIsoDateTime(notification.body);
    if (at != null) {
      return 'A driver requested an appointment for '
          '${_monthShort(at.month)} ${at.day} at ${_formatHourMinute(at)}.';
    }
    return 'A driver requested a new appointment. Open Appointments to review it.';
  }
  return _sanitizeNotificationText(notification.body);
}

/// Notifications screen: fetches from GET /garages/notifications, list with unread count and "Mark all as read".
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isAppointmentRelated(NotificationEntity notification) {
    if (notification.type == NotificationType.newAppointmentRequest ||
        notification.type == NotificationType.appointmentConfirmed ||
        notification.type == NotificationType.appointmentReminder) {
      return true;
    }

    final haystack =
        '${notification.title} ${notification.body}'.toLowerCase();
    return haystack.contains('appointment') ||
        haystack.contains('service status') ||
        haystack.contains('rescheduled') ||
        haystack.contains('cancelled') ||
        haystack.contains('approved') ||
        haystack.contains('rejected');
  }

  void _handleNotificationTap(NotificationEntity notification) {
    context.read<NotificationBloc>().add(MarkNotificationRead(notification.id));

    if (_isAppointmentRelated(notification)) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: BlocBuilder<NotificationBloc, NotificationState>(
          buildWhen: (prev, curr) =>
              curr is NotificationLoaded || curr is NotificationInitial,
          builder: (context, state) {
            final unread = state is NotificationLoaded
                ? state.unreadCount
                : 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$unread unread',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            buildWhen: (prev, curr) => curr is NotificationLoaded,
            builder: (context, state) {
              if (state is! NotificationLoaded ||
                  state.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  context
                      .read<NotificationBloc>()
                      .add(const MarkAllNotificationsRead());
                },
                child: Text(
                  'Mark all as read',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is NotificationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton.icon(
                      onPressed: () {
                        context
                            .read<NotificationBloc>()
                            .add(const LoadNotifications());
                      },
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text('Retry'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is NotificationLoaded) {
            final list = state.notifications;
            if (list.isEmpty) {
              return Center(
                child: Text(
                  'No notifications yet',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final n = list[index];
                return _NotificationCard(
                  notification: n,
                  onTap: () => _handleNotificationTap(n),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final NotificationEntity notification;
  final VoidCallback onTap;

  static ({Color bg, IconData icon}) _styleFor(NotificationType type) {
    switch (type) {
      case NotificationType.newAppointmentRequest:
      case NotificationType.appointmentConfirmed:
        return (bg: const Color(0xFFB3E5FC), icon: Icons.calendar_today_rounded);
      case NotificationType.serviceCompleted:
      case NotificationType.paymentReceived:
        return (bg: const Color(0xFFC8E6C9), icon: Icons.check_circle_rounded);
      case NotificationType.appointmentReminder:
        return (bg: const Color(0xFFFFE0B2), icon: Icons.notifications_active_rounded);
      case NotificationType.systemUpdate:
      case NotificationType.general:
        return (bg: const Color(0xFFE1BEE7), icon: Icons.notifications_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(notification.type);
    final isUnread = !notification.read;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: isUnread
            ? (notification.type == NotificationType.serviceCompleted
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFFDE7))
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: style.bg,
                    borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  ),
                  child: Icon(style.icon, color: AppColors.textPrimary, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _friendlyNotificationTitle(notification),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _friendlyNotificationBody(notification),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (notification.timestamp != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _timeAgo(notification.timestamp),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
