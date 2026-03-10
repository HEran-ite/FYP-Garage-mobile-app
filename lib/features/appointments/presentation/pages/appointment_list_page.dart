import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/appointment_model.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import '../bloc/appointment_state.dart';

/// Appointment list page: exact UI with filter chips, sleek cards, and status-based actions.
class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  @override
  void initState() {
    super.initState();
    context.read<AppointmentBloc>().add(const LoadAppointments());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointments',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Manage your service appointments',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (state is AppointmentLoaded) _FilterChips(state: state),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AppointmentState state) {
    if (state is AppointmentLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }
    if (state is AppointmentLoaded) {
      final list = state.filteredList;
      if (list.isEmpty) {
        return Center(
          child: Text(
            'No appointments',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: list.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _AppointmentCard(
            appointment: list[index],
            actionLoadingId: state is AppointmentActionLoading
                ? (state as AppointmentActionLoading).appointmentId
                : null,
          ),
        ),
      );
    }
    if (state is AppointmentError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () =>
                    context.read<AppointmentBloc>().add(const LoadAppointments()),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.state});

  final AppointmentLoaded state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AppointmentBloc>();
    final filters = [
      (AppointmentListFilter.all, 'All', state.countAll),
      (AppointmentListFilter.pending, 'Pending', state.countPending),
      (AppointmentListFilter.approved, 'Approved', state.countApproved),
      (AppointmentListFilter.inProgress, 'In Progress', state.countInProgress),
      (AppointmentListFilter.completed, 'Completed', state.countCompleted),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          for (final f in filters)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => bloc.add(SetAppointmentFilter(f.$1)),
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: state.filter == f.$1
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.full),
                      border: state.filter == f.$1
                          ? null
                          : Border.all(
                              color: AppColors.inputBorder,
                              width: 1,
                            ),
                    ),
                    child: Text(
                      '${f.$2} (${f.$3})',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: state.filter == f.$1
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: state.filter == f.$1
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    this.actionLoadingId,
  });

  final AppointmentModel appointment;
  final String? actionLoadingId;

  /// Backend does not return driver name; show placeholder until API extends.
  String get _customerName => 'Driver';

  /// Backend does not return vehicle/plate; placeholders until API extends.
  String get _vehicle => '—';
  String get _plate => '—';
  String get _contact => '—';
  String get _date => appointment.scheduledAtDisplay.split(',').first.trim();
  String get _time =>
      appointment.scheduledAtDisplay.contains(',')
          ? appointment.scheduledAtDisplay.split(',').last.trim()
          : '—';
  String get _serviceLocation =>
      appointment.serviceDescription.isNotEmpty
          ? '${appointment.serviceDescription} • At Garage'
          : '— • At Garage';

  @override
  Widget build(BuildContext context) {
    final loading = actionLoadingId == appointment.id;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: customer name + status pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _customerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                ),
              ),
              _StatusPill(status: appointment.statusLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Vehicle
          Text(
            _vehicle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // License plate
          Text(
            _plate,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Detail rows with teal/blue icons
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            text: _date,
          ),
          const SizedBox(height: AppSpacing.xs),
          _DetailRow(
            icon: Icons.access_time_rounded,
            text: _time,
          ),
          const SizedBox(height: AppSpacing.xs),
          _DetailRow(
            icon: Icons.location_on_outlined,
            text: _serviceLocation,
          ),
          const SizedBox(height: AppSpacing.xs),
          _DetailRow(
            icon: Icons.phone_outlined,
            text: _contact,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionButtons(
            appointment: appointment,
            loading: loading,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }
}

/// Status pill colors to match design: dark text on light background.
Color _statusBgColor(String label) {
  switch (label) {
    case 'Pending':
      return const Color(0xFFFEF3C7); // light yellow
    case 'Approved':
      return const Color(0xFFDBEAFE); // light blue
    case 'In Progress':
      return const Color(0xFFFED7AA); // light orange
    case 'Completed':
      return const Color(0xFFD1FAE5); // light green
    case 'Rejected':
    case 'Cancelled':
      return const Color(0xFFFEE2E2); // light red
    default:
      return AppColors.textSecondary.withOpacity(0.12);
  }
}

Color _statusFgColor(String label) {
  switch (label) {
    case 'Pending':
      return const Color(0xFFB45309); // dark yellow/amber
    case 'Approved':
      return const Color(0xFF1D4ED8); // dark blue
    case 'In Progress':
      return const Color(0xFFC2410C); // dark orange
    case 'Completed':
      return const Color(0xFF047857); // dark green
    case 'Rejected':
    case 'Cancelled':
      return AppColors.error; // red
    default:
      return AppColors.textSecondary;
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _statusBgColor(status),
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _statusFgColor(status),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.appointment,
    required this.loading,
  });

  final AppointmentModel appointment;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AppointmentBloc>();
    if (loading) {
      return const Padding(
        padding: EdgeInsets.only(top: AppSpacing.sm),
        child: SizedBox(
          height: 28,
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
        ),
      );
    }
    if (appointment.isPending) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => bloc.add(ApproveAppointment(appointment.id)),
                icon: const Icon(Icons.check, size: 20, color: Colors.white),
                label: const Text('Approve'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => bloc.add(RejectAppointment(appointment.id)),
                icon: const Icon(Icons.close, size: 20, color: Colors.white),
                label: const Text('Reject'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (appointment.isApproved) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () =>
                bloc.add(StartServiceAppointment(appointment.id)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              elevation: 0,
            ),
            child: const Text('Start Service'),
          ),
        ),
      );
    }
    if (appointment.isInProgress) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              // View details – navigate when detail screen exists
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              elevation: 0,
            ),
            child: const Text('View Details'),
          ),
        ),
      );
    }
    // Completed: no action buttons
    return const SizedBox.shrink();
  }
}
