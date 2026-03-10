import 'package:equatable/equatable.dart';

/// Registration data entity (all steps combined)
class RegistrationEntity extends Equatable {
  const RegistrationEntity({
    required this.garageName,
    required this.phone,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.address,
    required this.services,
    this.otherServices,
    this.businessLicensePath,
    this.latitude,
    this.longitude,
    this.placeId,
  });

  final String garageName;
  final String phone;
  final String email;
  final String password;
  final String confirmPassword;
  final String address;
  final List<String> services;
  final String? otherServices;
  final String? businessLicensePath;
  final double? latitude;
  final double? longitude;
  /// Google Place ID for garage_location (backend requires a valid value)
  final String? placeId;

  @override
  List<Object?> get props =>
      [garageName, phone, email, password, confirmPassword, address, services, otherServices, businessLicensePath, latitude, longitude, placeId];
}
