import '../entities/dashboard_stats.dart';
import '../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

/// Dashboard repository interface
abstract class DashboardRepository {
  Future<Either<Failure, DashboardStats>> getDashboardStats();
}

