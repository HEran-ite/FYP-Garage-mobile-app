import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/locale/appointment_localization.dart';
import '../../../../core/locale/date_localization.dart';
import '../../../../core/locale/l10n_extension.dart';
import '../../../../core/locale/service_localization.dart';
import '../../../../core/locale/date_localization.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection_container.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../appointments/presentation/bloc/appointment_bloc.dart';
import '../../../appointments/presentation/bloc/appointment_event.dart';
import '../../../appointments/presentation/bloc/appointment_state.dart';
import '../../../appointments/presentation/pages/appointment_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/pages/set_availability_page.dart';
import '../../../services/presentation/pages/service_list_page.dart';
import '../../../availability/domain/repositories/availability_repository.dart';

/// Dashboard page - Overview of garage activity with stats, quick actions, and upcoming appointments
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider<NotificationBloc>(
      create: (_) => sl<NotificationBloc>()..add(const LoadNotifications()),
      child: BlocProvider<AppointmentBloc>(
        create: (_) => sl<AppointmentBloc>(),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: _selectedIndex == 0
              ? _DashboardContent(
                  onViewAppointments: () => setState(() => _selectedIndex = 1),
                  onUpdateAvailability: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SetAvailabilityPage(
                          repository: sl<AvailabilityRepository>(),
                        ),
                      ),
                    );
                  },
                )
              : _selectedIndex == 1
              ? const AppointmentListPage()
              : _selectedIndex == 2
              ? const ServiceListPage()
              : const ProfilePage(),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.dashboard_rounded,
                      label: l10n.navDashboard,
                      isSelected: _selectedIndex == 0,
                      onTap: () => setState(() => _selectedIndex = 0),
                    ),
                    _NavItem(
                      icon: Icons.calendar_today_rounded,
                      label: l10n.navAppointments,
                      isSelected: _selectedIndex == 1,
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                    _NavItem(
                      icon: Icons.build_circle_outlined,
                      label: l10n.navServices,
                      isSelected: _selectedIndex == 2,
                      onTap: () => setState(() => _selectedIndex = 2),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      label: l10n.navProfile,
                      isSelected: _selectedIndex == 3,
                      onTap: () => setState(() => _selectedIndex = 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent({this.onViewAppointments, this.onUpdateAvailability});

  final VoidCallback? onViewAppointments;
  final VoidCallback? onUpdateAvailability;

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent>
    with WidgetsBindingObserver {
  static const Duration _statusRefreshInterval = Duration(seconds: 20);
  Timer? _statusRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<AppointmentBloc>().add(const LoadAppointments());
    _refreshStatusFromBackend();
    _statusRefreshTimer = Timer.periodic(
      _statusRefreshInterval,
      (_) => _refreshStatusFromBackend(),
    );
  }

  @override
  void dispose() {
    _statusRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStatusFromBackend();
    }
  }

  void _refreshStatusFromBackend() {
    if (!mounted) return;
    context.read<AuthBloc>().add(const AuthRefreshProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (_, state) => state is AuthLoginSuccess,
      builder: (context, authState) {
        final l10n = context.l10n;
        final garageName = authState is AuthLoginSuccess
            ? (authState.user.name.isEmpty ? l10n.myGarage : authState.user.name)
            : l10n.myGarage;
        final garageStatus = authState is AuthLoginSuccess
            ? authState.user.garageStatus
            : null;
        return BlocBuilder<AppointmentBloc, AppointmentState>(
          builder: (context, appointmentState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    _DashboardHeader(
                      garageName: garageName,
                      garageStatus: garageStatus,
                      onOpenAppointmentTab: widget.onViewAppointments,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _StatsGrid(state: appointmentState),
                    const SizedBox(height: AppSpacing.xl),
                    _QuickActionsSection(
                      onViewAppointments: widget.onViewAppointments,
                      onUpdateAvailability: widget.onUpdateAvailability,
                      pendingCount: appointmentState is AppointmentLoaded
                          ? appointmentState.countPending
                          : 0,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _UpcomingAppointmentsSection(
                      onViewAll: widget.onViewAppointments,
                      state: appointmentState,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.garageName,
    this.onOpenAppointmentTab,
    this.garageStatus,
  });

  final String garageName;
  final VoidCallback? onOpenAppointmentTab;
  final String? garageStatus;

  static Color _garageStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'ACTIVE':
        return AppColors.success;
      case 'PENDING':
      case 'WARNED':
        return AppColors.warning;
      case 'REJECTED':
      case 'BLOCKED':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusLabel = localizedGarageStatus(l10n, garageStatus).label;
    final statusColor = _garageStatusColor(garageStatus);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dashboard,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                garageName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  border: Border.all(
                    color: statusColor.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: statusColor),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            final showBadge =
                state is NotificationLoaded && state.unreadCount > 0;
            return IconButton(
              onPressed: () async {
                final result = await Navigator.of(
                  context,
                ).pushNamed(RoutePaths.notifications);
                if (result == true) {
                  onOpenAppointmentTab?.call();
                }
              },
              icon: Badge(
                isLabelVisible: showBadge,
                smallSize: 8,
                child: Icon(
                  Icons.notifications_outlined,
                  color: showBadge
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.state});

  final AppointmentState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loaded = state is AppointmentLoaded
        ? state as AppointmentLoaded
        : null;
    final all = loaded?.countAll ?? 0;
    final pending = loaded?.countPending ?? 0;
    final inProgress = loaded?.countInProgress ?? 0;
    final completed = loaded?.countCompleted ?? 0;

    if (state is AppointmentLoading) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.15,
      children: [
        _StatCard(
          icon: Icons.calendar_today_rounded,
          iconColor: AppColors.info,
          value: '$all',
          label: l10n.statsTodayAppointments,
        ),
        _StatCard(
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.warning,
          value: '$pending',
          label: l10n.statsPendingRequests,
        ),
        _StatCard(
          icon: Icons.schedule_rounded,
          iconColor: AppColors.secondary,
          value: '$inProgress',
          label: l10n.statsInProgress,
        ),
        _StatCard(
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.success,
          value: '$completed',
          label: l10n.statsCompletedToday,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({
    this.onViewAppointments,
    this.onUpdateAvailability,
    this.pendingCount = 0,
  });

  final VoidCallback? onViewAppointments;
  final VoidCallback? onUpdateAvailability;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.quickActions,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: onViewAppointments,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            elevation: 0,
          ),
          child: Text(l10n.viewAppointmentRequests(pendingCount)),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: onUpdateAvailability,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.inputBorder),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
          ),
          child: Text(l10n.updateAvailability),
        ),
      ],
    );
  }
}

class _UpcomingAppointmentsSection extends StatelessWidget {
  const _UpcomingAppointmentsSection({this.onViewAll, required this.state});

  final VoidCallback? onViewAll;
  final AppointmentState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final list = state is AppointmentLoaded
        ? (state as AppointmentLoaded).appointments.take(3).toList()
        : <AppointmentModel>[];
    final isLoading = state is AppointmentLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.upcomingAppointments,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                l10n.viewAll,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          )
        else if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              l10n.noUpcomingAppointments,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          ...list.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _DashboardAppointmentCard(appointment: a),
            ),
          ),
      ],
    );
  }
}

class _DashboardAppointmentCard extends StatelessWidget {
  const _DashboardAppointmentCard({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isConfirmed = appointment.isApproved || appointment.isCompleted;
    final display =
        formatScheduledAtDisplay(l10n, appointment.scheduledAt);
    final timePart = display.contains(',')
        ? display.split(',').last.trim()
        : display;
    final serviceLabel = localizedServiceLabel(
      l10n,
      appointment.serviceDescription,
    );
    final statusLabel = localizedAppointmentStatus(l10n, appointment.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.driver,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            serviceLabel,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isConfirmed
                  ? AppColors.success.withOpacity(0.12)
                  : AppColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppBorderRadius.full),
            ),
            child: Text(
              statusLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isConfirmed ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                timePart,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.lg),
              Icon(
                Icons.build_circle_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  serviceLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
