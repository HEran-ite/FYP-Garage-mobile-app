import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationReadUseCase {
  MarkNotificationReadUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Either<Failure, void>> call(String notificationId) =>
      _repository.markNotificationRead(notificationId);
}
