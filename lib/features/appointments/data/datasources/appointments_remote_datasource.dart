import '../models/appointment_model.dart';

/// Remote data source for garage appointments (list, get, approve, reject, update status).
abstract class AppointmentsRemoteDataSource {
  /// [status] optional filter: PENDING, APPROVED, IN_SERVICE, COMPLETED, etc.
  /// [search] optional query for backend search (e.g. GET /garage/appointments?search=...).
  Future<List<AppointmentModel>> listAppointments({String? status, String? search});

  Future<AppointmentModel> getAppointment(String id);

  Future<AppointmentModel> approveAppointment(String id);

  Future<AppointmentModel> rejectAppointment(String id);

  /// [status] must be IN_SERVICE or COMPLETED.
  Future<AppointmentModel> updateStatus(String id, String status);
}
