import 'package:equatable/equatable.dart';

/// User entity for authenticated garage owner (profile + optional location & services)
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.placeId,
    this.services,
    this.otherServices,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? placeId;
  final List<String>? services;
  final String? otherServices;

  @override
  List<Object?> get props => [id, name, email, phone, address, latitude, longitude, placeId, services, otherServices];
}
