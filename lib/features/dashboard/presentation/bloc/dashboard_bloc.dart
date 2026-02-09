import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Dashboard BLoC - Manages dashboard state and business logic
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    // TODO: Implement data loading logic
    // - Call use case
    // - Handle success/error
    emit(const DashboardLoaded());
  }
}
