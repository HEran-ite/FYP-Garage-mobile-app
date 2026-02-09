import 'package:equatable/equatable.dart';

/// Events for Profile BLoC
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load profile event
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

