import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/constants/auth_constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../injection/injection_container.dart';
import '../../../availability/domain/repositories/availability_repository.dart';
import 'profile_edit_page.dart';
import 'services_edit_page.dart';
import 'set_availability_page.dart';

/// Profile & Settings: garage info, availability, services, settings toggles, logout.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _onsiteService = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) => curr is AuthLoginSuccess || curr is AuthInitial,
      builder: (context, state) {
        if (state is! AuthLoginSuccess) {
          return const Center(child: Text('Please sign in'));
        }
        final user = state.user;
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
                _AvailabilityCard(onTap: () => _openSetAvailability(context)),
                const SizedBox(height: AppSpacing.md),
                _ServicesOfferedCard(
                  services: user.services,
                  otherServices: user.otherServices,
                  onTap: () => _openServicesEdit(context, user),
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsCard(
                  onsiteService: _onsiteService,
                  notifications: _notifications,
                  onOnsiteChanged: (v) => setState(() => _onsiteService = v),
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
    );
  }

  void _openProfileEdit(BuildContext context, dynamic user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileEditPage(user: user),
      ),
    );
  }

  void _openServicesEdit(BuildContext context, dynamic user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServicesEditPage(user: user),
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
  const _AvailabilityCard({this.onTap});

  final VoidCallback? onTap;

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
                      'Open 6 days a week',
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

class _ServicesOfferedCard extends StatelessWidget {
  const _ServicesOfferedCard({
    this.services,
    this.otherServices,
    this.onTap,
  });

  final List<String>? services;
  final String? otherServices;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fromPredefined = (services ?? [])
        .where((s) => s != AuthConstants.otherServiceId)
        .toList();
    final fromCustom = otherServices != null && otherServices!.isNotEmpty
        ? otherServices!.split(RegExp(r',\s*')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
        : <String>[];
    final labels = [...fromPredefined, ...fromCustom];
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
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Text(
                    'Services Offered',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (labels.isEmpty)
                Text(
                  'Tap to add services',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                )
              else
                for (final label in labels)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
                    ),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
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
