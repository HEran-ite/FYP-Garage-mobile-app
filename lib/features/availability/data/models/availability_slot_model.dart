/// One availability slot for a day. Backend: dayOfWeek (MONDAY..SUNDAY), startMinute, endMinute; response includes startTime, endTime (HH:mm).
class AvailabilitySlotModel {
  const AvailabilitySlotModel({
    required this.id,
    required this.garageId,
    required this.dayOfWeek,
    required this.startMinute,
    required this.endMinute,
    required this.startTime,
    required this.endTime,
  });

  final String id;
  final String garageId;
  final String dayOfWeek;
  final int startMinute;
  final int endMinute;
  final String startTime;
  final String endTime;

  factory AvailabilitySlotModel.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlotModel(
      id: json['id'] as String? ?? '',
      garageId: json['garageId'] as String? ?? '',
      dayOfWeek: json['dayOfWeek'] as String? ?? 'MONDAY',
      startMinute: json['startMinute'] as int? ?? 0,
      endMinute: json['endMinute'] as int? ?? 0,
      startTime: json['startTime'] as String? ?? '00:00',
      endTime: json['endTime'] as String? ?? '00:00',
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
      };
}
