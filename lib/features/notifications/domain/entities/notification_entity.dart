/// A single notification item for the garage owner.
class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.timestamp,
    this.read = false,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime? timestamp;
  final bool read;

  NotificationEntity copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? read,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
    );
  }
}

enum NotificationType {
  newAppointmentRequest,
  serviceCompleted,
  appointmentReminder,
  systemUpdate,
  appointmentConfirmed,
  paymentReceived,
  /// Backend notifications without a specific type
  general,
}
