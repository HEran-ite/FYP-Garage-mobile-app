import '../../domain/entities/dashboard_stats.dart';

/// Dashboard stats data model (JSON serializable)
class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalAppointments,
    required super.pendingAppointments,
    required super.completedAppointments,
    required super.totalRevenue,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalAppointments: json['total_appointments'] as int,
      pendingAppointments: json['pending_appointments'] as int,
      completedAppointments: json['completed_appointments'] as int,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_appointments': totalAppointments,
      'pending_appointments': pendingAppointments,
      'completed_appointments': completedAppointments,
      'total_revenue': totalRevenue,
    };
  }
}

