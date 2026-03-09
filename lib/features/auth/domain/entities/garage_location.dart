import 'package:equatable/equatable.dart';

/// Garage location (exact pin) linked to a garage profile.
/// Stored securely on the backend when the garage owner registers.
class GarageLocation extends Equatable {
  const GarageLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;

  @override
  List<Object?> get props => [latitude, longitude, address];
}
