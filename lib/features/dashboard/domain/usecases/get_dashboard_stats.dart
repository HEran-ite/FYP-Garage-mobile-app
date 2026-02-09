import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';
import '../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

/// Use case to get dashboard statistics
class GetDashboardStats {
  final DashboardRepository repository;

  GetDashboardStats(this.repository);

  Future<Either<Failure, DashboardStats>> call() {
    return repository.getDashboardStats();
  }
}

