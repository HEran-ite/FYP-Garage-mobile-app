import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/error/user_friendly_errors.dart';
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
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    context.read<AppointmentBloc>().add(const LoadAppointments());
    _searchController.addListener(_onSearchChanged);
  }

  /// Debounce and request appointments from backend with search query (no client-side filtering).
  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final query = _searchController.text.trim();
      context.read<AppointmentBloc>().add(LoadAppointments(
        search: query.isEmpty ? null : query,
      ));
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentError) {
          final msg = toUserFriendlyMessage(state.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
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
              _SearchBar(
                controller: _searchController,
                hint: 'Search by vehicle, plate number or driver name',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (state is AppointmentLoaded || state is AppointmentActionLoading)
                _FilterChips(state: state),
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
    AppointmentLoaded? loaded;
    AppointmentActionLoading? actionLoading;
    if (state is AppointmentLoaded) loaded = state;
    if (state is AppointmentActionLoading) actionLoading = state;
    // List comes from backend only (search is server-side via ?search=). Status chips filter that list in memory.
    final list = loaded?.filteredList ?? actionLoading?.filteredList;
    final loadingId = actionLoading?.appointmentId;
    if (list != null && list.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<AppointmentBloc>().add(const LoadAppointments());
        },
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: list.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _AppointmentCard(
              appointment: list[index],
              actionLoadingId: loadingId,
            ),
          ),
        ),
      );
    }
    if (list != null && list.isEmpty) {
      final hasSearch = (loaded?.searchQuery ?? actionLoading?.searchQuery)?.isNotEmpty == true;
      return Center(
        child: Text(
          hasSearch ? 'No appointments match your search' : 'No appointments',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
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
                toUserFriendlyMessage(state.message),
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.hint,
  });

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          prefixIcon: Icon(Icons.search_rounded, size: 22, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.state});

  final AppointmentState state;

  @override
  Widget build(BuildContext context) {
    if (state is! AppointmentLoaded && state is! AppointmentActionLoading) {
      return const SizedBox.shrink();
    }
    final s = state;
    final countAll = s is AppointmentLoaded ? s.countAll : (s as AppointmentActionLoading).countAll;
    final countPending = s is AppointmentLoaded ? s.countPending : (s as AppointmentActionLoading).countPending;
    final countApproved = s is AppointmentLoaded ? s.countApproved : (s as AppointmentActionLoading).countApproved;
    final countInProgress = s is AppointmentLoaded ? s.countInProgress : (s as AppointmentActionLoading).countInProgress;
    final countCompleted = s is AppointmentLoaded ? s.countCompleted : (s as AppointmentActionLoading).countCompleted;
    final countRejected = s is AppointmentLoaded ? s.countRejected : (s as AppointmentActionLoading).countRejected;
    final filter = s is AppointmentLoaded ? s.filter : (s as AppointmentActionLoading).filter;

    final bloc = context.read<AppointmentBloc>();
    final filters = [
      (AppointmentListFilter.all, 'All', countAll),
      (AppointmentListFilter.pending, 'Pending', countPending),
      (AppointmentListFilter.approved, 'Approved', countApproved),
      (AppointmentListFilter.inProgress, 'In Progress', countInProgress),
      (AppointmentListFilter.completed, 'Completed', countCompleted),
      (AppointmentListFilter.rejected, 'Rejected', countRejected),
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
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: filter == f.$1
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.full),
                      border: filter == f.$1
                          ? null
                          : Border.all(
                              color: AppColors.inputBorder,
                              width: 1,
                            ),
                    ),
                    child: Text(
                      '${f.$2} (${f.$3})',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontSize: 15,
                            color: filter == f.$1
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: filter == f.$1
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

  /// From driver.firstName + driver.lastName (or driverName fallback).
  String get _customerName =>
      appointment.driverName?.isNotEmpty == true ? appointment.driverName! : 'Driver';

  /// From vehicles[].name (or first vehicle / vehicleName fallback). Multiple joined with ", ".
  String get _vehicle {
    if (appointment.vehicles.isNotEmpty) {
      final names = appointment.vehicles.map((v) => v.name).where((s) => s.isNotEmpty && s != '—').toList();
      if (names.isNotEmpty) return names.join(', ');
    }
    return appointment.vehicleName?.isNotEmpty == true ? appointment.vehicleName! : '—';
  }

  /// From vehicles[].plate (or first plate / plateNumber fallback). Multiple joined with ", ".
  String get _plate {
    if (appointment.vehicles.isNotEmpty) {
      final plates = appointment.vehicles.map((v) => v.plate).where((s) => s.isNotEmpty && s != '—').toList();
      if (plates.isNotEmpty) return plates.join(', ');
    }
    return appointment.plateNumber?.isNotEmpty == true ? appointment.plateNumber! : '—';
  }

  /// From driver.phone.
  String get _contact =>
      appointment.driverPhone?.isNotEmpty == true ? appointment.driverPhone! : '—';
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
          // Top row: customer name + status chip (dropdown)
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
              _StatusChipDropdown(
                appointment: appointment,
                loading: loading,
              ),
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

/// Backend status values and display labels for the status dropdown.
const List<({String value, String label})> _statusOptions = [
  (value: 'PENDING', label: 'Pending'),
  (value: 'APPROVED', label: 'Approved'),
  (value: 'REJECTED', label: 'Rejected'),
  (value: 'IN_SERVICE', label: 'In Progress'),
  (value: 'COMPLETED', label: 'Completed'),
  (value: 'CANCELLED', label: 'Cancelled'),
];

/// Status chip in the card header; tap to open dropdown and change status.
class _StatusChipDropdown extends StatelessWidget {
  const _StatusChipDropdown({
    required this.appointment,
    required this.loading,
  });

  final AppointmentModel appointment;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AppointmentBloc>();
    final currentLabel = appointment.statusLabel;
    final bg = _statusBgColor(currentLabel);
    final fg = _statusFgColor(currentLabel);

    if (loading) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
        ),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: fg,
          ),
        ),
      );
    }

    return PopupMenuButton<String>(
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      elevation: 8,
      shadowColor: Colors.black26,
      color: AppColors.surface,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 160),
      itemBuilder: (context) => _statusOptions
          .map((e) => PopupMenuItem<String>(
                value: e.value,
                height: 42,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _statusBgColor(e.label),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      e.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight:
                                e.label == currentLabel ? FontWeight.w600 : FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ))
          .toList(),
      onSelected: (String newStatus) {
        final currentValue = appointment.status.toUpperCase();
        if (newStatus != currentValue) {
          bloc.add(UpdateAppointmentStatus(appointment.id, newStatus));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: fg),
          ],
        ),
      ),
    );
  }
}
