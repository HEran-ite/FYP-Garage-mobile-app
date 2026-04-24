class GarageRatingModel {
  const GarageRatingModel({
    required this.id,
    required this.rating,
    this.comment,
    this.createdAt,
    this.driverName,
    this.appointmentId,
    this.appointmentScheduledAt,
    this.appointmentStatus,
  });

  final String id;
  final double rating;
  final String? comment;
  final DateTime? createdAt;
  final String? driverName;
  final String? appointmentId;
  final DateTime? appointmentScheduledAt;
  final String? appointmentStatus;

  factory GarageRatingModel.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'];
    final firstName = driver is Map ? (driver['firstName']?.toString() ?? '') : '';
    final lastName = driver is Map ? (driver['lastName']?.toString() ?? '') : '';
    final fullName = '$firstName $lastName'.trim();

    final ratingRaw = json['rating'];
    final rating = ratingRaw is num
        ? ratingRaw.toDouble()
        : double.tryParse(ratingRaw?.toString() ?? '') ?? 0;

    final createdAtRaw = json['createdAt']?.toString();
    final createdAt = createdAtRaw == null ? null : DateTime.tryParse(createdAtRaw);
    final appointment = json['appointment'];
    final appointmentId = appointment is Map ? appointment['id']?.toString() : null;
    final appointmentStatus = appointment is Map
        ? appointment['status']?.toString()
        : null;
    final appointmentScheduledAtRaw = appointment is Map
        ? appointment['scheduledAt']?.toString()
        : null;
    final appointmentScheduledAt = appointmentScheduledAtRaw == null
        ? null
        : DateTime.tryParse(appointmentScheduledAtRaw);

    return GarageRatingModel(
      id: json['id']?.toString() ?? '',
      rating: rating,
      comment: json['comment']?.toString(),
      createdAt: createdAt,
      driverName: fullName.isEmpty ? null : fullName,
      appointmentId: appointmentId,
      appointmentScheduledAt: appointmentScheduledAt,
      appointmentStatus: appointmentStatus,
    );
  }
}
