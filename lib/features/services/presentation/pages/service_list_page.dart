import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/error/user_friendly_errors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/service_chip_grid.dart';

/// Services tab: edit services directly (chip grid + Save), no extra navigation.
class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  List<String> _selectedServices = [];
  List<String> _customServiceNames = [];
  bool _isSaving = false;
  bool _hasInitialized = false;

  void _syncFromUser(UserEntity user) {
    // Backend returns service names; support slugs from session for backward compat
    final allNames = (user.services ?? [])
        .map((s) => AuthConstants.serviceSlugToLabel[s] ?? s)
        .where((s) => s.isNotEmpty)
        .toList();
    _selectedServices = allNames
        .where((label) => AuthConstants.serviceOptionsPredefined.contains(label))
        .toList();
    final customFromServices = allNames
        .where((label) => !AuthConstants.serviceOptionsPredefined.contains(label))
        .toList();
    final customFromOther = user.otherServices != null && user.otherServices!.isNotEmpty
        ? user.otherServices!.split(RegExp(r',\s*')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
        : <String>[];
    _customServiceNames = [...customFromServices];
    for (final c in customFromOther) {
      if (!_customServiceNames.contains(c)) _customServiceNames.add(c);
    }
  }

  void _save(UserEntity user) {
    setState(() => _isSaving = true);
    context.read<AuthBloc>().add(AuthServicesUpdated(
          garageId: user.id,
          serviceLabels: _selectedServices,
          otherServices: _customServiceNames.isEmpty
              ? null
              : _customServiceNames.join(', '),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          curr is AuthProfileUpdateError || (curr is AuthLoginSuccess && _isSaving),
      listener: (context, state) {
        if (state is AuthProfileUpdateError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(toUserFriendlyMessage(state.message))),
          );
        } else if (state is AuthLoginSuccess && _isSaving) {
          setState(() {
            _isSaving = false;
            _syncFromUser(state.user);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Services saved')),
          );
        }
      },
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
        final UserEntity? user = state is AuthLoginSuccess
            ? state.user
            : state is AuthProfileUpdating
                ? state.user
                : state is AuthProfileUpdateError
                    ? state.user
                    : null;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Please sign in')),
          );
        }
        if (!_hasInitialized) {
          _hasInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final s = context.read<AuthBloc>().state;
              if (s is AuthLoginSuccess) {
                setState(() => _syncFromUser(s.user));
              }
            }
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Services You Provide',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Select and manage the services your garage offers.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Services offered',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${_selectedServices.length + _customServiceNames.length} selected',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ServiceChipGrid(
                    selectedServices: _selectedServices,
                    onSelectionChanged: (v) => setState(() => _selectedServices = v),
                    customServiceNames: _customServiceNames,
                    onCustomServiceNamesChanged: (v) => setState(() => _customServiceNames = v),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: _isSaving ? null : () => _save(user),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
