import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/error/user_friendly_errors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../injection/injection_container.dart';
import '../../../availability/domain/repositories/availability_repository.dart';
import '../../../settings/data/datasources/garage_settings_remote_datasource.dart';
import 'profile_edit_page.dart';
import 'set_availability_page.dart';

/// Profile & Settings: garage info, availability, services, settings toggles, logout.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _onsiteService = false;
  bool _notifications = true;
  int? _availabilityDaysCount;
  bool _loadingSettings = false;

  @override
  void initState() {
    super.initState();
    _loadAvailabilityDaysCount();
    _loadGarageSettings();
  }

  Future<void> _loadGarageSettings() async {
    setState(() => _loadingSettings = true);
    try {
      final data = await sl<GarageSettingsRemoteDataSource>().getSettings();
      final enabled = data['onsiteServiceEnabled'];
      if (!mounted) return;
      setState(() {
        _onsiteService = enabled is bool ? enabled : false;
        _loadingSettings = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSettings = false);
    }
  }

  Future<void> _setOnsiteServiceEnabled(bool enabled) async {
    final prev = _onsiteService;
    setState(() => _onsiteService = enabled);
    try {
      await sl<GarageSettingsRemoteDataSource>().updateSettings({
        'onsiteServiceEnabled': enabled,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _onsiteService = prev);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(toUserFriendlyMessage(e.toString()))),
      );
    }
  }

  Future<void> _loadAvailabilityDaysCount() async {
    try {
      final slots = await sl<AvailabilityRepository>().listSlots();
      final days = slots.map((s) => s.dayOfWeek).toSet().length;
      if (mounted) setState(() => _availabilityDaysCount = days);
    } catch (_) {
      if (mounted) setState(() => _availabilityDaysCount = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) =>
          curr is AuthLoginSuccess ||
          curr is AuthProfileUpdating ||
          curr is AuthProfileUpdateError ||
          curr is AuthInitial ||
          curr is AuthRestoringSession,
      builder: (context, state) {
        if (state is AuthRestoringSession) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = state is AuthLoginSuccess
            ? state.user
            : state is AuthProfileUpdating
                ? state.user
                : state is AuthProfileUpdateError
                    ? state.user
                    : null;
        if (user == null) {
          return const Center(child: Text('Please sign in'));
        }
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Profile & Settings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Manage your garage information',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _GarageInfoCard(
                  name: user.name,
                  phone: user.phone,
                  email: user.email,
                  address: user.address,
                  onEdit: () => _openProfileEdit(context, user),
                ),
                const SizedBox(height: AppSpacing.md),
                _AvailabilityCard(
                  openDaysCount: _availabilityDaysCount,
                  onTap: () => _openSetAvailability(context),
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsCard(
                  onsiteService: _onsiteService,
                  notifications: _notifications,
                  onOnsiteChanged: (v) {
                    if (_loadingSettings) return;
                    _setOnsiteServiceEnabled(v);
                  },
                  onNotificationsChanged: (v) => setState(() => _notifications = v),
                ),
                const SizedBox(height: AppSpacing.lg),
                _LogoutButton(
                  onPressed: () => _logout(context),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSetAvailability(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SetAvailabilityPage(repository: sl<AvailabilityRepository>()),
      ),
    ).then((_) => _loadAvailabilityDaysCount());
  }

  void _openProfileEdit(BuildContext context, dynamic user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileEditPage(user: user),
      ),
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    Navigator.of(context).pushNamedAndRemoveUntil(
      RoutePaths.login,
      (_) => false,
    );
  }
}

class _GarageInfoCard extends StatelessWidget {
  const _GarageInfoCard({
    required this.name,
    required this.phone,
    required this.email,
    this.address,
    this.onEdit,
  });

  final String name;
  final String phone;
  final String email;
  final String? address;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: AppColors.textPrimary, width: 1.5),
                ),
                child: const Icon(
                  Icons.garage_rounded,
                  size: 28,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Garage' : name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '4.8 (142 reviews)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: 24),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(icon: Icons.phone_outlined, text: phone.isEmpty ? '—' : phone),
          const SizedBox(height: AppSpacing.xs),
          _InfoRow(icon: Icons.email_outlined, text: email.isEmpty ? '—' : email),
          const SizedBox(height: AppSpacing.xs),
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: address?.isNotEmpty == true
                ? address!
                : 'Tap edit to set address',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    this.openDaysCount,
    this.onTap,
  });

  /// Number of days with availability set (from API). Null = loading.
  final int? openDaysCount;

  final VoidCallback? onTap;

  String get _subtitle {
    if (openDaysCount == null) return 'Loading...';
    if (openDaysCount! == 0) return 'No availability set';
    if (openDaysCount! == 1) return 'Open 1 day a week';
    return 'Open $openDaysCount days a week';
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Availability',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onTap,
                icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.onsiteService,
    required this.notifications,
    required this.onOnsiteChanged,
    required this.onNotificationsChanged,
  });

  final bool onsiteService;
  final bool notifications;
  final ValueChanged<bool> onOnsiteChanged;
  final ValueChanged<bool> onNotificationsChanged;

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingRow(
            icon: Icons.location_on_outlined,
            title: 'Onsite Service',
            subtitle: 'Offer services at customer location',
            value: onsiteService,
            onChanged: onOnsiteChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingRow(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Receive appointment alerts',
            value: notifications,
            onChanged: onNotificationsChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary.withOpacity(0.6),
        ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout, size: 22, color: Colors.white),
        label: const Text('Logout'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
