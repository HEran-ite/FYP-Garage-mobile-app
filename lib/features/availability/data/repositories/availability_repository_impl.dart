import '../../domain/repositories/availability_repository.dart';
import '../datasources/availability_remote_datasource.dart';
import '../models/availability_slot_model.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  AvailabilityRepositoryImpl(this._remote);

  final AvailabilityRemoteDataSource _remote;

  @override
  Future<List<AvailabilitySlotModel>> listSlots({String? dayOfWeek}) =>
      _remote.listSlots(dayOfWeek: dayOfWeek);

  @override
  Future<AvailabilitySlotModel> createSlot({
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) =>
      _remote.createSlot(
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      );

  @override
  Future<AvailabilitySlotModel> updateSlot(
    String id, {
    String? dayOfWeek,
    String? startTime,
    String? endTime,
  }) =>
      _remote.updateSlot(id, dayOfWeek: dayOfWeek, startTime: startTime, endTime: endTime);

  @override
  Future<void> deleteSlot(String id) => _remote.deleteSlot(id);
}
