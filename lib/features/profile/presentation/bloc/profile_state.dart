import 'package:equatable/equatable.dart';

/// States for Profile BLoC
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {}

/// Loading state
class ProfileLoading extends ProfileState {}

/// Loaded state
class ProfileLoaded extends ProfileState {
  // TODO: Add profile data
  const ProfileLoaded();
}

/// Error state
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

