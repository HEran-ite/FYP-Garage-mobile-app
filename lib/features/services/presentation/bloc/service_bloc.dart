import 'package:flutter_bloc/flutter_bloc.dart';
import 'service_event.dart';
import 'service_state.dart';

/// Service BLoC
class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  ServiceBloc() : super(ServiceInitial()) {
    on<LoadServices>(_onLoadServices);
  }

  Future<void> _onLoadServices(
    LoadServices event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());
    // TODO: Implement
    emit(const ServiceLoaded());
  }
}

