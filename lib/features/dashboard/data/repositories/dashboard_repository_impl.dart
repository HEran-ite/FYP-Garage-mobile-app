import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../core/error/failures.dart';
import '../datasources/dashboard_remote_datasource.dart';
import 'package:dartz/dartz.dart';

/// Implementation of DashboardRepository
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      final result = await remoteDataSource.getDashboardStats();
      return Right(result);
    } catch (e) {
      // TODO: Map exceptions to failures
      return Left(ServerFailure(e.toString()));
    }
  }
}

