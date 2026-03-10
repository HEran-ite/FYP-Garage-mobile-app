/// Appointment model matching backend AppointmentResponseDto.
/// Backend returns: id, driverId, garageId, scheduledAt, serviceDescription, status, createdAt, updatedAt.
class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.driverId,
    required this.garageId,
    required this.scheduledAt,
    required this.serviceDescription,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String driverId;
  final String garageId;
  final String scheduledAt;
  final String serviceDescription;
  final String status;
  final String createdAt;
  final String updatedAt;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String? ?? '',
      driverId: json['driverId'] as String? ?? '',
      garageId: json['garageId'] as String? ?? '',
      scheduledAt: json['scheduledAt'] as String? ?? '',
      serviceDescription: json['serviceDescription'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  /// Display label for status (e.g. "In Progress" for IN_SERVICE)
  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      case 'IN_SERVICE':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isApproved => status.toUpperCase() == 'APPROVED';
  bool get isInProgress => status.toUpperCase() == 'IN_SERVICE';
  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isRejected => status.toUpperCase() == 'REJECTED';

  /// e.g. "2026-02-05, 10:00 AM" for display.
  String get scheduledAtDisplay {
    if (scheduledAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(scheduledAt);
      final date = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$date, $hour:$minute $period';
    } catch (_) {
      return scheduledAt;
    }
  }
}
