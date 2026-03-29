import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/user_friendly_errors.dart';
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
    on<UpdateAppointmentStatus>(_onUpdateStatus);
  }

  final AppointmentsRepository _repository;

  Future<void> _onLoadAppointments(
    LoadAppointments event,
    Emitter<AppointmentState> emit,
  ) async {
    final preservedFilter = state is AppointmentLoaded
        ? (state as AppointmentLoaded).filter
        : state is AppointmentActionLoading
            ? (state as AppointmentActionLoading).filter
            : AppointmentListFilter.all;
    emit(AppointmentLoading());
    try {
      final list = await _repository.listAppointments(search: event.search);
      final query = event.search?.trim().isEmpty == true ? null : event.search?.trim();
      emit(AppointmentLoaded(
        appointments: list,
        filter: preservedFilter,
        searchQuery: query,
      ));
    } catch (e) {
      emit(AppointmentError(toUserFriendlyMessage(e.toString())));
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
        searchQuery: loaded.searchQuery,
      ));
    }
  }

  Future<void> _onApprove(
    ApproveAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentLoaded) return;
    emit(AppointmentActionLoading(event.id, appointments: current.appointments, filter: current.filter, searchQuery: current.searchQuery));
    try {
      await _repository.approveAppointment(event.id);
      final list = await _repository.listAppointments(search: current.searchQuery);
      emit(AppointmentLoaded(
        appointments: list,
        filter: current.filter,
        searchQuery: current.searchQuery,
      ));
    } catch (e) {
      emit(AppointmentLoaded(
        appointments: current.appointments,
        filter: current.filter,
        searchQuery: current.searchQuery,
      ));
      emit(AppointmentError(toUserFriendlyMessage(e.toString())));
    }
  }

  Future<void> _onReject(
    RejectAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentLoaded) return;
    emit(AppointmentActionLoading(event.id, appointments: current.appointments, filter: current.filter, searchQuery: current.searchQuery));
    try {
      await _repository.rejectAppointment(event.id);
      final list = await _repository.listAppointments(search: current.searchQuery);
      emit(AppointmentLoaded(
        appointments: list,
        filter: current.filter,
        searchQuery: current.searchQuery,
      ));
    } catch (e) {
      emit(AppointmentLoaded(
        appointments: current.appointments,
        filter: current.filter,
        searchQuery: current.searchQuery,
      ));
      emit(AppointmentError(toUserFriendlyMessage(e.toString())));
    }
  }

  Future<void> _onStartService(
    StartServiceAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentLoaded) return;
    emit(AppointmentActionLoading(event.id, appointments: current.appointments, filter: current.filter, searchQuery: current.searchQuery));
    try {
      await _repository.updateStatus(event.id, 'IN_SERVICE');
      final list = await _repository.listAppointments(search: current.searchQuery);
      emit(AppointmentLoaded(
        appointments: list,
        filter: current.filter,
        searchQuery: current.searchQuery,
      ));
    } catch (e) {
      emit(AppointmentLoaded(
        appointments: current.appointments,
        filter: current.filter,
        searchQuery: current.searchQuery,
      ));
      emit(AppointmentError(toUserFriendlyMessage(e.toString())));
    }
  }

  Future<void> _onCompleteService(
    CompleteServiceAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentLoaded) return;
    emit(AppointmentActionLoading(event.id, appointments: current.appointments, filter: current.filter, searchQuery: current.searchQuery));
    try {
      await _repository.updateStatus(event.id, 'COMPLETED');
      final list = await _repository.listAppointments(search: current.searchQuery);
      emit(AppointmentLoaded(
        appointments: list,
        filter: current.filter,
        searchQuery: current.searchQuery,
      ));
    } catch (e) {
      emit(AppointmentLoaded(
        appointments: current.appointments,
        filter: current.filter,
        searchQuery: current.searchQuery,
      ));
      emit(AppointmentError(toUserFriendlyMessage(e.toString())));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateAppointmentStatus event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentLoaded) return;
    emit(AppointmentActionLoading(event.id, appointments: current.appointments, filter: current.filter, searchQuery: current.searchQuery));
    try {
      await _repository.updateStatus(event.id, event.status);
      final list = await _repository.listAppointments(search: current.searchQuery);
      emit(AppointmentLoaded(
        appointments: list,
        filter: current.filter,
        searchQuery: current.searchQuery,
      ));
    } catch (e) {
      emit(AppointmentLoaded(
        appointments: current.appointments,
        filter: current.filter,
        searchQuery: current.searchQuery,
      ));
      emit(AppointmentError(toUserFriendlyMessage(e.toString())));
    }
  }
}
