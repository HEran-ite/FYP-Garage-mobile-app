import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/error/user_friendly_errors.dart';
import '../../domain/entities/registration_entity.dart';
import '../../domain/usecases/clear_session_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import '../../domain/usecases/update_garage_services_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth BLoC - login and multi-step registration
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UpdateGarageServicesUseCase updateGarageServicesUseCase,
    required RestoreSessionUseCase restoreSessionUseCase,
    required ClearSessionUseCase clearSessionUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _updateGarageServicesUseCase = updateGarageServicesUseCase,
        _restoreSessionUseCase = restoreSessionUseCase,
        _clearSessionUseCase = clearSessionUseCase,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRestoreSession>(_onRestoreSession);
    on<AuthRefreshProfileRequested>(_onRefreshProfileRequested);
    on<AuthRegistrationStarted>(_onRegistrationStarted);
    on<AuthRegistrationStep1Next>(_onRegistrationStep1Next);
    on<AuthRegistrationStep2Next>(_onRegistrationStep2Next);
    on<AuthRegistrationStep2Back>(_onRegistrationStep2Back);
    on<AuthRegistrationStep3Back>(_onRegistrationStep3Back);
    on<AuthRegistrationSubmitted>(_onRegistrationSubmitted);
    on<AuthRegistrationSuccessDismissed>(_onRegistrationSuccessDismissed);
    on<AuthRegistrationCancelled>(_onRegistrationCancelled);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionInvalidated>(_onSessionInvalidated);
    on<AuthProfileUpdated>(_onProfileUpdated);
    on<AuthServicesUpdated>(_onServicesUpdated);
  }

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UpdateGarageServicesUseCase _updateGarageServicesUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;
  final ClearSessionUseCase _clearSessionUseCase;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoginLoading());
    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthLoginError(toUserFriendlyMessage(failure.message))),
      (user) => emit(AuthLoginSuccess(user)),
    );
  }

  void _onRegistrationStarted(
    AuthRegistrationStarted event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthRegistrationStep1());
  }

  void _onRegistrationStep1Next(
    AuthRegistrationStep1Next event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthRegistrationStep2(RegistrationStep1Data(
      garageName: event.garageName,
      phone: event.phone,
      email: event.email,
      password: event.password,
      confirmPassword: event.confirmPassword,
    )));
  }

  void _onRegistrationStep2Next(
    AuthRegistrationStep2Next event,
    Emitter<AuthState> emit,
  ) {
    final state = this.state;
    if (state is! AuthRegistrationStep2) return;
    emit(AuthRegistrationStep3(state.step1Data, RegistrationStep2Data(
      address: event.address,
      services: event.services,
      otherServices: event.otherServices,
      latitude: event.latitude,
      longitude: event.longitude,
      placeId: event.placeId,
    )));
  }

  void _onRegistrationStep2Back(
    AuthRegistrationStep2Back event,
    Emitter<AuthState> emit,
  ) {
    final state = this.state;
    if (state is AuthRegistrationStep2) {
      emit(AuthRegistrationStep1(restore: state.step1Data));
      return;
    }
    emit(const AuthRegistrationStep1());
  }

  void _onRegistrationStep3Back(
    AuthRegistrationStep3Back event,
    Emitter<AuthState> emit,
  ) {
    final state = this.state;
    if (state is AuthRegistrationStep3) {
      emit(AuthRegistrationStep2(
        state.step1Data,
        restoreStep2: state.step2Data,
      ));
      return;
    }
    if (state is AuthRegistrationSubmitting) {
      emit(AuthRegistrationStep2(
        state.step1Data,
        restoreStep2: state.step2Data,
      ));
      return;
    }
    if (state is AuthRegistrationError &&
        state.step1Data != null &&
        state.step2Data != null) {
      emit(AuthRegistrationStep2(
        state.step1Data!,
        restoreStep2: state.step2Data,
      ));
    }
  }

  Future<void> _onRegistrationSubmitted(
    AuthRegistrationSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final state = this.state;
    late final RegistrationStep1Data s1;
    late final RegistrationStep2Data s2;
    if (state is AuthRegistrationStep3) {
      s1 = state.step1Data;
      s2 = state.step2Data;
    } else if (state is AuthRegistrationError &&
        state.step1Data != null &&
        state.step2Data != null) {
      s1 = state.step1Data!;
      s2 = state.step2Data!;
    } else {
      return;
    }
    emit(AuthRegistrationSubmitting(step1Data: s1, step2Data: s2));
    final entity = RegistrationEntity(
      garageName: s1.garageName,
      phone: AuthConstants.normalizePhoneForApi(s1.phone),
      email: s1.email,
      password: s1.password,
      confirmPassword: s1.confirmPassword,
      address: s2.address,
      services: s2.services,
      otherServices: s2.otherServices,
      businessLicensePath: event.businessLicensePath,
      latitude: s2.latitude,
      longitude: s2.longitude,
      placeId: s2.placeId,
    );
    final result = await _registerUseCase(
      entity,
      licenseBytes: event.businessLicenseBytes,
      licenseFileName: event.businessLicenseFileName,
    );
    result.fold(
      (failure) => emit(AuthRegistrationError(
        toUserFriendlyMessage(failure.message),
        step1Data: s1,
        step2Data: s2,
      )),
      (user) => emit(AuthRegistrationSuccess(user, s1.garageName)),
    );
  }

  void _onRegistrationSuccessDismissed(
    AuthRegistrationSuccessDismissed event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthInitial());
  }

  void _onRegistrationCancelled(
    AuthRegistrationCancelled event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthInitial());
  }

  Future<void> _onRestoreSession(
    AuthRestoreSession event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthRestoringSession());
    final user = await _restoreSessionUseCase();
    if (user != null) {
      emit(AuthLoginSuccess(user));
    } else {
      emit(const AuthInitial());
    }
  }

  Future<void> _onRefreshProfileRequested(
    AuthRefreshProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final previousState = state;
    final user = await _restoreSessionUseCase();
    if (user != null) {
      if (previousState is AuthLoginSuccess && previousState.user == user) {
        return;
      }
      emit(AuthLoginSuccess(user));
      return;
    }
    if (previousState is AuthLoginSuccess ||
        previousState is AuthProfileUpdating ||
        previousState is AuthProfileUpdateError) {
      emit(const AuthInitial());
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _clearSessionUseCase();
    emit(const AuthInitial());
  }

  Future<void> _onSessionInvalidated(
    AuthSessionInvalidated event,
    Emitter<AuthState> emit,
  ) async {
    await _clearSessionUseCase();
    emit(const AuthInitial());
  }

  Future<void> _onProfileUpdated(
    AuthProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;
    emit(AuthProfileUpdating(user));
    final result = await _updateProfileUseCase(user);
    result.fold(
      (failure) => emit(AuthProfileUpdateError(toUserFriendlyMessage(failure.message), user)),
      (updatedUser) => emit(AuthLoginSuccess(updatedUser)),
    );
  }

  Future<void> _onServicesUpdated(
    AuthServicesUpdated event,
    Emitter<AuthState> emit,
  ) async {
    final state = this.state;
    if (state is! AuthLoginSuccess) return;
    final user = state.user;
    emit(AuthProfileUpdating(user));
    // Use human-readable service names; backend services API expects names.
    final slugs = List<String>.from(event.serviceLabels);
    final result = await _updateGarageServicesUseCase(
      event.garageId,
      slugs,
      event.otherServices,
    );
    result.fold(
      (failure) => emit(AuthProfileUpdateError(toUserFriendlyMessage(failure.message), user)),
      (updatedUser) => emit(AuthLoginSuccess(updatedUser)),
    );
  }
}
