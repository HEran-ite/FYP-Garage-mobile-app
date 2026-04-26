import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/user_friendly_errors.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(
    this._getNotifications,
    this._markNotificationRead,
    this._markAllNotificationsRead,
  ) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
  }

  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markNotificationRead;
  final MarkAllNotificationsReadUseCase _markAllNotificationsRead;

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

  Future<void> _onMarkRead(
    MarkNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoaded) return;
    final loaded = state as NotificationLoaded;

    final result = await _markNotificationRead(event.id);
    if (result.isLeft()) return;

    final list = loaded.notifications
        .map((n) => n.id == event.id ? n.copyWith(read: true) : n)
        .toList();
    emit(NotificationLoaded(list));
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoaded) return;
    final loaded = state as NotificationLoaded;

    final result = await _markAllNotificationsRead();
    if (result.isLeft()) return;

    final list = loaded.notifications
        .map((n) => n.copyWith(read: true))
        .toList();
    emit(NotificationLoaded(list));
  }
}
