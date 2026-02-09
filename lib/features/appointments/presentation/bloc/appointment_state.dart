import 'package:equatable/equatable.dart';

/// States for Appointment BLoC
abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AppointmentInitial extends AppointmentState {}

/// Loading state
class AppointmentLoading extends AppointmentState {}

/// Loaded state
class AppointmentLoaded extends AppointmentState {
  // TODO: Add appointments list
  const AppointmentLoaded();
}

/// Error state
class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError(this.message);

  @override
  List<Object?> get props => [message];
}

