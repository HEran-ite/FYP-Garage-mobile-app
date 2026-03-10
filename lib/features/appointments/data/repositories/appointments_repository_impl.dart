import '../../domain/repositories/appointments_repository.dart';
import '../datasources/appointments_remote_datasource.dart';
import '../models/appointment_model.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  AppointmentsRepositoryImpl(this._remote);

  final AppointmentsRemoteDataSource _remote;

  @override
  Future<List<AppointmentModel>> listAppointments({String? status}) =>
      _remote.listAppointments(status: status);

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
  Future<AppointmentModel> updateStatus(String id, String status) =>
      _remote.updateStatus(id, status);
}
