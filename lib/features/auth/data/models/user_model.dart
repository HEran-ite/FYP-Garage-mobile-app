import 'dart:convert';

import '../../domain/entities/user_entity.dart';

/// User model for API/serialization.
/// Login response: { token, garage } -> use fromGarageJson(garage).
/// Signup 201 response: { id, garage_name, email, phone, ... } -> use fromSignupJson(body).
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.address,
    super.latitude,
    super.longitude,
    super.placeId,
    super.services,
    super.otherServices,
  });

  /// From login response garage object. Parses location from top-level or garage_location.
  factory UserModel.fromGarageJson(Map<String, dynamic> json) {
    String? address;
    double? lat;
    double? lng;
    String? placeId;
    List<String>? servicesList;
    String? otherStr;

    final loc = json['garage_location'];
    if (loc != null) {
      if (loc is Map) {
        address = loc['address'] as String?;
        lat = _toDouble(loc['latitude']);
        lng = _toDouble(loc['longitude']);
        placeId = loc['place_id'] as String?;
      } else if (loc is String) {
        try {
          final m = (jsonDecode(loc) as Map<String, dynamic>?);
          if (m != null) {
            address = m['address'] as String?;
            lat = _toDouble(m['latitude']);
            lng = _toDouble(m['longitude']);
            placeId = m['place_id'] as String?;
          }
        } catch (_) {}
      }
    }
    if (address == null) address = json['address'] as String?;
    if (lat == null) lat = _toDouble(json['latitude']);
    if (lng == null) lng = _toDouble(json['longitude']);
    if (placeId == null) placeId = json['place_id'] as String?;

    final soff = json['services_offered'];
    if (soff is List) {
      servicesList = soff.map((e) => e.toString()).toList();
    }
    otherStr = json['other_services'] as String?;

    return UserModel(
      id: _stringId(json['id']),
      name: (json['name'] as String?) ?? (json['garage_name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      address: address,
      latitude: lat,
      longitude: lng,
      placeId: placeId,
      services: servicesList,
      otherServices: otherStr,
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  /// From signup 201 response (id, garage_name, email, phone)
  factory UserModel.fromSignupJson(Map<String, dynamic> json) {
    return UserModel(
      id: _stringId(json['id']),
      name: (json['garage_name'] as String?) ?? (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
    );
  }

  static String _stringId(dynamic id) {
    if (id == null) return '';
    if (id is String) return id;
    return id.toString();
  }

  /// Copy with updated profile fields (for profile edit)
  UserModel copyWithProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? placeId,
    List<String>? services,
    String? otherServices,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      services: services ?? this.services,
      otherServices: otherServices ?? this.otherServices,
    );
  }

  /// Full JSON for session persistence (SharedPreferences).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        if (address != null) 'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (placeId != null) 'place_id': placeId,
        if (services != null) 'services_offered': services,
        if (otherServices != null) 'other_services': otherServices,
      };

  /// From stored session JSON (same shape as toJson / garage response).
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel.fromGarageJson(json);
}
