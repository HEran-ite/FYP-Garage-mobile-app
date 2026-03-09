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
  });

  /// From login response garage object (Prisma: id, name, email, phone)
  factory UserModel.fromGarageJson(Map<String, dynamic> json) {
    return UserModel(
      id: _stringId(json['id']),
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
    );
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
      };
}
