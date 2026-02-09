import 'package:equatable/equatable.dart';

/// Events for Dashboard BLoC
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load dashboard data
class LoadDashboardData extends DashboardEvent {
  const LoadDashboardData();
}
