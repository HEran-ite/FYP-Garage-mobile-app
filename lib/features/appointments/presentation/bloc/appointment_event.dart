import 'package:equatable/equatable.dart';

/// Events for Appointment BLoC
abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

/// Load appointments event
class LoadAppointments extends AppointmentEvent {
  const LoadAppointments();
}

