import '../models/dashboard_stats_model.dart';
import '../../../../core/error/exceptions.dart';

/// Remote data source for dashboard data
abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
}

/// Implementation of remote data source
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  // TODO: Inject API client
  // final ApiClient apiClient;

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    // TODO: Implement API call
    // - Make HTTP request
    // - Parse response
    // - Handle exceptions
    throw const ServerException('Not implemented');
  }
}

