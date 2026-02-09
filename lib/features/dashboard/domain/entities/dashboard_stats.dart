/// Dashboard statistics entity
class DashboardStats {
  final int totalAppointments;
  final int pendingAppointments;
  final int completedAppointments;
  final double totalRevenue;

  const DashboardStats({
    required this.totalAppointments,
    required this.pendingAppointments,
    required this.completedAppointments,
    required this.totalRevenue,
  });
}

