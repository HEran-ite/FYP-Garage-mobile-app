import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/service_chip_grid.dart';

/// Edit services offered only: predefined chips + custom services.
class ServicesEditPage extends StatefulWidget {
  const ServicesEditPage({super.key, required this.user});

  final UserEntity user;

  @override
  State<ServicesEditPage> createState() => _ServicesEditPageState();
}

class _ServicesEditPageState extends State<ServicesEditPage> {
  List<String> _selectedServices = [];
  List<String> _customServiceNames = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    // Backend returns slugs; chip grid uses labels.
    _selectedServices = (u.services ?? [])
        .map((s) => AuthConstants.serviceSlugToLabel[s] ?? s)
        .where((label) => AuthConstants.serviceOptionsPredefined.contains(label))
        .toList();
    _customServiceNames = u.otherServices != null && u.otherServices!.isNotEmpty
        ? u.otherServices!.split(RegExp(r',\s*')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
        : [];
  }

  void _save() {
    final updated = UserModel(
      id: widget.user.id,
      name: widget.user.name,
      email: widget.user.email,
      phone: widget.user.phone,
      address: widget.user.address,
      latitude: widget.user.latitude,
      longitude: widget.user.longitude,
      placeId: widget.user.placeId,
      services: _selectedServices.isEmpty ? null : List.from(_selectedServices),
      otherServices: _customServiceNames.isEmpty
          ? null
          : _customServiceNames.join(', '),
    );
    setState(() => _isSaving = true);
    context.read<AuthBloc>().add(AuthProfileUpdated(updated));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileUpdateError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthLoginSuccess && _isSaving) {
          setState(() => _isSaving = false);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Services saved')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Edit Services',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
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
                onPressed: _isSaving ? null : _save,
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
  }
}
