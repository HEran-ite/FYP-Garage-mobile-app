import 'package:equatable/equatable.dart';

/// Filter for appointment list (maps to backend status or "all").
enum AppointmentListFilter {
  all,
  pending,
  approved,
  inProgress,
  completed,
}

/// Events for Appointment BLoC
abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

/// Load all appointments (then filter in state).
class LoadAppointments extends AppointmentEvent {
  const LoadAppointments();
}

/// Change the active filter (client-side, no reload).
class SetAppointmentFilter extends AppointmentEvent {
  const SetAppointmentFilter(this.filter);

  final AppointmentListFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Approve a pending appointment.
class ApproveAppointment extends AppointmentEvent {
  const ApproveAppointment(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Reject a pending appointment.
class RejectAppointment extends AppointmentEvent {
  const RejectAppointment(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Start service (set status to IN_SERVICE).
class StartServiceAppointment extends AppointmentEvent {
  const StartServiceAppointment(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Mark appointment as completed (set status to COMPLETED).
class CompleteServiceAppointment extends AppointmentEvent {
  const CompleteServiceAppointment(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
