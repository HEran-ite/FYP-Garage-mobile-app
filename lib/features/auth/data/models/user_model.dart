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
    super.garageStatus,
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
    } else if (json['services'] is List) {
      // Backend GarageProfileResponse: services is array of { id, name, ... }
      final arr = json['services'] as List;
      final list = <String>[];
      for (final s in arr) {
        final n = s is Map ? (s['name'] as String?)?.trim() : s.toString().trim();
        if (n != null && n.isNotEmpty) list.add(n);
      }
      servicesList = list.isEmpty ? null : list;
    }
    otherStr = json['other_services'] as String?;
    final status = json['status'] as String?;

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
      garageStatus: status != null && status.isNotEmpty ? status.toUpperCase() : null,
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  /// From signup 201 response (id, garage_name, email, phone, status)
  factory UserModel.fromSignupJson(Map<String, dynamic> json) {
    final status = json['status'] as String?;
    return UserModel(
      id: _stringId(json['id']),
      name: (json['garage_name'] as String?) ?? (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      garageStatus: status != null && status.isNotEmpty ? status.toUpperCase() : null,
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
    String? garageStatus,
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
      garageStatus: garageStatus ?? this.garageStatus,
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
    if (garageStatus != null) 'status': garageStatus,
  };

  /// From stored session JSON (same shape as toJson / garage response).
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel.fromGarageJson(json);
}
