import 'package:flutter_bloc/flutter_bloc.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

/// Appointment BLoC
class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  AppointmentBloc() : super(AppointmentInitial()) {
    on<LoadAppointments>(_onLoadAppointments);
  }

  Future<void> _onLoadAppointments(
    LoadAppointments event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    // TODO: Implement
    emit(const AppointmentLoaded());
  }
}

