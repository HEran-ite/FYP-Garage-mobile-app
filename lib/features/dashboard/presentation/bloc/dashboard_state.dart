import 'package:equatable/equatable.dart';

/// States for Dashboard BLoC
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DashboardInitial extends DashboardState {}

/// Loading state
class DashboardLoading extends DashboardState {}

/// Loaded state
class DashboardLoaded extends DashboardState {
  // TODO: Add dashboard data properties
  const DashboardLoaded();
}

/// Error state
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

