/// Appointment model matching backend response with nested driver and vehicles.
/// Example: { id, driverId, garageId, scheduledAt, serviceDescription, status,
///   driver: { id, firstName, lastName, email, phone },
///   vehicles: [...] and/or vehicle: { make, model, plateNumber, ... } }
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
    this.vehicleName,
    this.plateNumber,
    this.driverName,
    this.driverPhone,
    this.vehicles = const [],
  });

  final String id;
  final String driverId;
  final String garageId;
  final String scheduledAt;
  final String serviceDescription;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? vehicleName;
  final String? plateNumber;
  final String? driverName;
  final String? driverPhone;
  /// Parsed from backend vehicles array: e.g. [{ name, plateNumber }].
  final List<({String name, String plate})> vehicles;

  static String? _str(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is num || v is bool) return v.toString();
    return null;
  }

  static String _serviceDescription(dynamic v) {
    final asString = _str(v);
    if (asString != null) return asString;
    if (v is Map) {
      final m = Map<String, dynamic>.from(v);
      return _str(m['label']) ??
          _str(m['name']) ??
          _str(m['slug']) ??
          _str(m['description']) ??
          '';
    }
    return '';
  }

  static ({String name, String plate}) _vehicleFromMap(Map<String, dynamic> m) {
    final make = (_str(m['make']) ?? '').trim();
    final model = (_str(m['model']) ?? '').trim();
    final fromName = (_str(m['name']) ?? '').trim();
    var display = fromName;
    if (display.isEmpty) {
      display = '$make $model'.trim();
    }
    if (display.isEmpty) {
      display = model.isNotEmpty ? model : make;
    }
    final plate = (_str(m['plateNumber']) ??
            _str(m['licensePlate']) ??
            _str(m['plate']) ??
            '')
        .trim();
    return (
      name: display.isEmpty ? '—' : display,
      plate: plate.isEmpty ? '—' : plate,
    );
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] is Map ? json['driver'] as Map<String, dynamic> : null;
    // Driver: { id, firstName, lastName, email, phone }
    String? dn;
    if (driver != null) {
      final first = (_str(driver['firstName']) ?? '').trim();
      final last = (_str(driver['lastName']) ?? '').trim();
      dn = '$first $last'.trim();
      if (dn.isEmpty) dn = _str(driver['email']);
    }
    dn ??= _str(json['driverName']) ?? _str(json['driver_name']);
    final dph = _str(driver?['phone']) ??
        _str(json['driverPhone']) ??
        _str(json['driver_phone']) ??
        _str(json['phone']);

    // Vehicles: array of { name?, model?, plateNumber?, licensePlate?, ... }
    final vehiclesRaw = json['vehicles'];
    List<({String name, String plate})> vehiclesList = [];
    String? firstVehicleName;
    String? firstPlate;
    if (vehiclesRaw is List && vehiclesRaw.isNotEmpty) {
      for (final e in vehiclesRaw) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        final entry = _vehicleFromMap(m);
        vehiclesList.add(entry);
        if (firstVehicleName == null && entry.name != '—') {
          firstVehicleName = entry.name;
        }
        if (firstPlate == null && entry.plate != '—') {
          firstPlate = entry.plate;
        }
      }
    }
    // Single nested `vehicle` object (not a string) — common garage API shape.
    final vehicleObj = json['vehicle'];
    if (vehiclesList.isEmpty && vehicleObj is Map) {
      final entry = _vehicleFromMap(Map<String, dynamic>.from(vehicleObj));
      vehiclesList = [entry];
      firstVehicleName ??= entry.name != '—' ? entry.name : null;
      firstPlate ??= entry.plate != '—' ? entry.plate : null;
    }
    // Fallbacks from top-level strings only (never cast [vehicle] map to String).
    if (firstVehicleName == null) {
      firstVehicleName =
          _str(json['vehicleName']) ?? _str(json['carName']);
    }
    if (firstPlate == null) {
      firstPlate = _str(json['plateNumber']) ??
          _str(json['licensePlate']) ??
          _str(json['plate']);
    }

    return AppointmentModel(
      id: _str(json['id']) ?? '',
      driverId: _str(json['driverId']) ?? '',
      garageId: _str(json['garageId']) ?? '',
      scheduledAt: _str(json['scheduledAt']) ?? '',
      serviceDescription: _serviceDescription(json['serviceDescription']),
      status: _str(json['status']) ?? 'PENDING',
      createdAt: _str(json['createdAt']) ?? '',
      updatedAt: _str(json['updatedAt']) ?? '',
      vehicleName: firstVehicleName?.trim().isEmpty == true ? null : firstVehicleName?.trim(),
      plateNumber: firstPlate?.trim().isEmpty == true ? null : firstPlate?.trim(),
      driverName: dn?.trim().isEmpty == true ? null : dn?.trim(),
      driverPhone: dph?.trim().isEmpty == true ? null : dph?.trim(),
      vehicles: vehiclesList,
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
