import 'package:equatable/equatable.dart';

import 'appointment_event.dart';
import '../../data/models/appointment_model.dart';

/// States for Appointment BLoC
abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoaded extends AppointmentState {
  const AppointmentLoaded({
    required this.appointments,
    this.filter = AppointmentListFilter.all,
    this.searchQuery,
  });

  final List<AppointmentModel> appointments;
  final AppointmentListFilter filter;
  /// Last search sent to backend (so reloads after actions keep the same search).
  final String? searchQuery;

  /// Filtered list for current tab, sorted recent to old (by scheduledAt descending).
  List<AppointmentModel> get filteredList {
    List<AppointmentModel> list;
    switch (filter) {
      case AppointmentListFilter.pending:
        list = appointments.where((a) => a.isPending).toList();
        break;
      case AppointmentListFilter.approved:
        list = appointments.where((a) => a.isApproved).toList();
        break;
      case AppointmentListFilter.inProgress:
        list = appointments.where((a) => a.isInProgress).toList();
        break;
      case AppointmentListFilter.completed:
        list = appointments.where((a) => a.isCompleted).toList();
        break;
      case AppointmentListFilter.rejected:
        list = appointments.where((a) => a.isRejected).toList();
        break;
      case AppointmentListFilter.all:
        list = List<AppointmentModel>.from(appointments);
        break;
    }
    list.sort((a, b) {
      final da = DateTime.tryParse(a.scheduledAt) ?? DateTime(0);
      final db = DateTime.tryParse(b.scheduledAt) ?? DateTime(0);
      return db.compareTo(da); // recent first (newest at top)
    });
    return list;
  }

  int get countAll => appointments.length;
  int get countPending => appointments.where((a) => a.isPending).length;
  int get countApproved => appointments.where((a) => a.isApproved).length;
  int get countInProgress => appointments.where((a) => a.isInProgress).length;
  int get countCompleted => appointments.where((a) => a.isCompleted).length;
  int get countRejected => appointments.where((a) => a.isRejected).length;

  @override
  List<Object?> get props => [appointments, filter, searchQuery];
}

/// Shown while one appointment is being updated; keeps list visible.
class AppointmentActionLoading extends AppointmentState {
  const AppointmentActionLoading(
    this.appointmentId, {
    required this.appointments,
    this.filter = AppointmentListFilter.all,
    this.searchQuery,
  });

  final String appointmentId;
  final List<AppointmentModel> appointments;
  final AppointmentListFilter filter;
  final String? searchQuery;

  /// Same as [AppointmentLoaded.filteredList] so list stays visible during update.
  List<AppointmentModel> get filteredList {
    List<AppointmentModel> list;
    switch (filter) {
      case AppointmentListFilter.pending:
        list = appointments.where((a) => a.isPending).toList();
        break;
      case AppointmentListFilter.approved:
        list = appointments.where((a) => a.isApproved).toList();
        break;
      case AppointmentListFilter.inProgress:
        list = appointments.where((a) => a.isInProgress).toList();
        break;
      case AppointmentListFilter.completed:
        list = appointments.where((a) => a.isCompleted).toList();
        break;
      case AppointmentListFilter.rejected:
        list = appointments.where((a) => a.isRejected).toList();
        break;
      case AppointmentListFilter.all:
        list = List<AppointmentModel>.from(appointments);
        break;
    }
    list.sort((a, b) {
      final da = DateTime.tryParse(a.scheduledAt) ?? DateTime(0);
      final db = DateTime.tryParse(b.scheduledAt) ?? DateTime(0);
      return db.compareTo(da);
    });
    return list;
  }

  int get countAll => appointments.length;
  int get countPending => appointments.where((a) => a.isPending).length;
  int get countApproved => appointments.where((a) => a.isApproved).length;
  int get countInProgress => appointments.where((a) => a.isInProgress).length;
  int get countCompleted => appointments.where((a) => a.isCompleted).length;
  int get countRejected => appointments.where((a) => a.isRejected).length;

  @override
  List<Object?> get props => [appointmentId, appointments, filter, searchQuery];
}

class AppointmentError extends AppointmentState {
  const AppointmentError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
