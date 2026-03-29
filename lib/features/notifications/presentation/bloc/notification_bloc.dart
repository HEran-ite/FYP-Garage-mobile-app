import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/user_friendly_errors.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(this._getNotifications) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
  }

  final GetNotificationsUseCase _getNotifications;

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await _getNotifications();
    result.fold(
      (failure) => emit(NotificationError(toUserFriendlyMessage(failure.message))),
      (list) => emit(NotificationLoaded(list)),
    );
  }

  void _onMarkRead(
    MarkNotificationRead event,
    Emitter<NotificationState> emit,
  ) {
    if (state is! NotificationLoaded) return;
    final loaded = state as NotificationLoaded;
    final list = loaded.notifications
        .map((n) => n.id == event.id ? n.copyWith(read: true) : n)
        .toList();
    emit(NotificationLoaded(list));
  }

  void _onMarkAllRead(
    MarkAllNotificationsRead event,
    Emitter<NotificationState> emit,
  ) {
    if (state is! NotificationLoaded) return;
    final loaded = state as NotificationLoaded;
    final list = loaded.notifications
        .map((n) => n.copyWith(read: true))
        .toList();
    emit(NotificationLoaded(list));
  }
}
