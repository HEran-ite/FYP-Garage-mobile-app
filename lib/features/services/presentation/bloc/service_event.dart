import 'package:equatable/equatable.dart';

/// Events for Service BLoC
abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object?> get props => [];
}

/// Load services event
class LoadServices extends ServiceEvent {
  const LoadServices();
}

