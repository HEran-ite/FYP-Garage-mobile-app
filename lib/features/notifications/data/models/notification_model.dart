import '../../domain/entities/notification_entity.dart';

/// Notification model from backend (GarageNotification: id, garageId, title, body, read, createdAt).
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.body,
    super.timestamp,
    super.read = false,
  });

  /// Backend returns array of { id, garageId, title, body, read, createdAt }.
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final title = (json['title'] as String?)?.trim() ?? '';
    final body = (json['body'] as String?)?.trim() ?? '';
    final read = json['read'] as bool? ?? false;
    DateTime? timestamp;
    final createdAt = json['createdAt'];
    if (createdAt != null) {
      if (createdAt is String) {
        timestamp = DateTime.tryParse(createdAt);
      } else if (createdAt is DateTime) {
        timestamp = createdAt;
      }
    }
    return NotificationModel(
      id: id,
      type: NotificationType.general,
      title: title,
      body: body,
      timestamp: timestamp,
      read: read,
    );
  }
}
