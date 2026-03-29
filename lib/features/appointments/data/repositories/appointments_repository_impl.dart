import '../../domain/repositories/appointments_repository.dart';
import '../datasources/appointments_remote_datasource.dart';
import '../models/appointment_model.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  AppointmentsRepositoryImpl(this._remote);

  final AppointmentsRemoteDataSource _remote;

  @override
  Future<List<AppointmentModel>> listAppointments({String? status, String? search}) =>
      _remote.listAppointments(status: status, search: search);

  @override
  Future<AppointmentModel> getAppointment(String id) =>
      _remote.getAppointment(id);

  @override
  Future<AppointmentModel> approveAppointment(String id) =>
      _remote.approveAppointment(id);

  @override
  Future<AppointmentModel> rejectAppointment(String id) =>
      _remote.rejectAppointment(id);

  @override
  Future<AppointmentModel> updateStatus(String id, String status) {
    final upper = status.toUpperCase();
    if (upper == 'APPROVED') return _remote.approveAppointment(id);
    if (upper == 'REJECTED') return _remote.rejectAppointment(id);
    return _remote.updateStatus(id, status);
  }
}
