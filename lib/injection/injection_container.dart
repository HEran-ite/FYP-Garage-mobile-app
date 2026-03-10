import 'package:get_it/get_it.dart';

import '../features/appointments/data/datasources/appointments_remote_datasource.dart';
import '../features/appointments/data/datasources/appointments_remote_datasource_impl.dart';
import '../features/appointments/data/repositories/appointments_repository_impl.dart';
import '../features/appointments/domain/repositories/appointments_repository.dart';
import '../features/appointments/presentation/bloc/appointment_bloc.dart';
import '../features/availability/data/datasources/availability_remote_datasource.dart';
import '../features/availability/data/datasources/availability_remote_datasource_impl.dart';
import '../features/availability/data/repositories/availability_repository_impl.dart';
import '../features/availability/domain/repositories/availability_repository.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../features/auth/data/datasources/auth_session_storage.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/clear_session_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/restore_session_usecase.dart';
import '../features/auth/domain/usecases/update_profile_usecase.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

final GetIt sl = GetIt.instance;

/// Sets up dependency injection (repositories, use cases, BLoCs, data sources)
Future<void> setupDependencyInjection() async {
  // Auth
  sl.registerLazySingleton<AuthSessionStorage>(() => AuthSessionStorageImpl());
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl()));
  sl.registerLazySingleton<UpdateProfileUseCase>(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton<RestoreSessionUseCase>(() => RestoreSessionUseCase(sl()));
  sl.registerLazySingleton<ClearSessionUseCase>(() => ClearSessionUseCase(sl()));
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      updateProfileUseCase: sl(),
      restoreSessionUseCase: sl(),
      clearSessionUseCase: sl(),
    ),
  );

  // Appointments (garage)
  sl.registerLazySingleton<AppointmentsRemoteDataSource>(
    () => AppointmentsRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AppointmentsRepository>(
    () => AppointmentsRepositoryImpl(sl()),
  );
  sl.registerFactory<AppointmentBloc>(
    () => AppointmentBloc(sl()),
  );

  // Availability (garage time slots)
  sl.registerLazySingleton<AvailabilityRemoteDataSource>(
    () => AvailabilityRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AvailabilityRepository>(
    () => AvailabilityRepositoryImpl(sl<AvailabilityRemoteDataSource>()),
  );
}
