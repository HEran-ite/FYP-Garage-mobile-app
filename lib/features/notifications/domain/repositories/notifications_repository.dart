import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotificationEntity>>> listNotifications();
  Future<Either<Failure, void>> markNotificationRead(String notificationId);
  Future<Either<Failure, void>> markAllNotificationsRead();
}
