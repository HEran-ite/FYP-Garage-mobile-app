import '../../data/models/appointment_model.dart';

abstract class AppointmentsRepository {
  Future<List<AppointmentModel>> listAppointments({String? status});

  Future<AppointmentModel> getAppointment(String id);

  Future<AppointmentModel> approveAppointment(String id);

  Future<AppointmentModel> rejectAppointment(String id);

  Future<AppointmentModel> updateStatus(String id, String status);
}
