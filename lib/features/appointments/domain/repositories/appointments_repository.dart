import '../../data/models/appointment_model.dart';

abstract class AppointmentsRepository {
  /// [search] passed to backend as query param (e.g. ?search=...) for server-side search.
  Future<List<AppointmentModel>> listAppointments({String? status, String? search});

  Future<AppointmentModel> getAppointment(String id);

  Future<AppointmentModel> approveAppointment(String id);

  Future<AppointmentModel> rejectAppointment(String id);

  Future<AppointmentModel> updateStatus(String id, String status);
}
