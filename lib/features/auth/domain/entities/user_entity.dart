import 'package:equatable/equatable.dart';

/// User entity for authenticated garage owner
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String phone;

  @override
  List<Object?> get props => [id, name, email, phone];
}
