import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/appointments_repository.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  AppointmentBloc(this._repository) : super(AppointmentInitial()) {
    on<LoadAppointments>(_onLoadAppointments);
    on<SetAppointmentFilter>(_onSetFilter);
    on<ApproveAppointment>(_onApprove);
    on<RejectAppointment>(_onReject);
    on<StartServiceAppointment>(_onStartService);
    on<CompleteServiceAppointment>(_onCompleteService);
  }

  final AppointmentsRepository _repository;

  Future<void> _onLoadAppointments(
    LoadAppointments event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      final list = await _repository.listAppointments();
      emit(AppointmentLoaded(
        appointments: list,
        filter: state is AppointmentLoaded
            ? (state as AppointmentLoaded).filter
            : AppointmentListFilter.all,
      ));
    } catch (e) {
      emit(AppointmentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onSetFilter(
    SetAppointmentFilter event,
    Emitter<AppointmentState> emit,
  ) {
    if (state is AppointmentLoaded) {
      final loaded = state as AppointmentLoaded;
      emit(AppointmentLoaded(
        appointments: loaded.appointments,
        filter: event.filter,
      ));
    }
  }

  Future<void> _onApprove(
    ApproveAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentLoaded) return;
    emit(AppointmentActionLoading(event.id));
    try {
      await _repository.approveAppointment(event.id);
      final list = await _repository.listAppointments();
      emit(AppointmentLoaded(
        appointments: list,
        filter: current.filter,
      ));
    } catch (e) {
      emit(AppointmentLoaded(
        appointments: current.appointments,
        filter: current.filter,
      ));
      emit(AppointmentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onReject(
    RejectAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentLoaded) return;
    emit(AppointmentActionLoading(event.id));
    try {
      await _repository.rejectAppointment(event.id);
      final list = await _repository.listAppointments();
      emit(AppointmentLoaded(
        appointments: list,
        filter: current.filter,
      ));
    } catch (e) {
      emit(AppointmentLoaded(
        appointments: current.appointments,
        filter: current.filter,
      ));
      emit(AppointmentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onStartService(
    StartServiceAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentLoaded) return;
    emit(AppointmentActionLoading(event.id));
    try {
      await _repository.updateStatus(event.id, 'IN_SERVICE');
      final list = await _repository.listAppointments();
      emit(AppointmentLoaded(
        appointments: list,
        filter: current.filter,
      ));
    } catch (e) {
      emit(AppointmentLoaded(
        appointments: current.appointments,
        filter: current.filter,
      ));
      emit(AppointmentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCompleteService(
    CompleteServiceAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentLoaded) return;
    emit(AppointmentActionLoading(event.id));
    try {
      await _repository.updateStatus(event.id, 'COMPLETED');
      final list = await _repository.listAppointments();
      emit(AppointmentLoaded(
        appointments: list,
        filter: current.filter,
      ));
    } catch (e) {
      emit(AppointmentLoaded(
        appointments: current.appointments,
        filter: current.filter,
      ));
      emit(AppointmentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
