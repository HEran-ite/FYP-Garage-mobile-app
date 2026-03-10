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
  });

  final List<AppointmentModel> appointments;
  final AppointmentListFilter filter;

  /// Filtered list for current tab.
  List<AppointmentModel> get filteredList {
    switch (filter) {
      case AppointmentListFilter.pending:
        return appointments.where((a) => a.isPending).toList();
      case AppointmentListFilter.approved:
        return appointments.where((a) => a.isApproved).toList();
      case AppointmentListFilter.inProgress:
        return appointments.where((a) => a.isInProgress).toList();
      case AppointmentListFilter.completed:
        return appointments.where((a) => a.isCompleted).toList();
      case AppointmentListFilter.all:
        return appointments;
    }
  }

  int get countAll => appointments.length;
  int get countPending => appointments.where((a) => a.isPending).length;
  int get countApproved => appointments.where((a) => a.isApproved).length;
  int get countInProgress => appointments.where((a) => a.isInProgress).length;
  int get countCompleted => appointments.where((a) => a.isCompleted).length;

  @override
  List<Object?> get props => [appointments, filter];
}

class AppointmentActionLoading extends AppointmentState {
  const AppointmentActionLoading(this.appointmentId);

  final String appointmentId;

  @override
  List<Object?> get props => [appointmentId];
}

class AppointmentError extends AppointmentState {
  const AppointmentError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
