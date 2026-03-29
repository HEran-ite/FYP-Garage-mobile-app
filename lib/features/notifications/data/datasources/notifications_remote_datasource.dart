import '../models/notification_model.dart';

/// Remote data source for garage notifications (GET /garages/notifications).
abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> listNotifications();
}
