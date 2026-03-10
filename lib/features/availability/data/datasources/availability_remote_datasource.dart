import '../models/availability_slot_model.dart';

abstract class AvailabilityRemoteDataSource {
  Future<List<AvailabilitySlotModel>> listSlots({String? dayOfWeek});
  Future<AvailabilitySlotModel> createSlot({
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  });
  Future<AvailabilitySlotModel> updateSlot(
    String id, {
    String? dayOfWeek,
    String? startTime,
    String? endTime,
  });
  Future<void> deleteSlot(String id);
}
