import 'package:equatable/equatable.dart';

/// States for Service BLoC
abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ServiceInitial extends ServiceState {}

/// Loading state
class ServiceLoading extends ServiceState {}

/// Loaded state
class ServiceLoaded extends ServiceState {
  // TODO: Add services list
  const ServiceLoaded();
}

/// Error state
class ServiceError extends ServiceState {
  final String message;

  const ServiceError(this.message);

  @override
  List<Object?> get props => [message];
}

