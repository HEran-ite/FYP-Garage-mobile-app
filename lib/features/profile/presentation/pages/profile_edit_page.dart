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
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/location_picker_field.dart';

/// Edit garage profile only: name, phone, email, address (with map).
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key, required this.user});

  final UserEntity user;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  double? _pickedLat;
  double? _pickedLng;
  String? _pickedPlaceId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u.name);
    _phoneController = TextEditingController(text: u.phone);
    _emailController = TextEditingController(text: u.email);
    _addressController = TextEditingController(text: u.address ?? '');
    _pickedLat = u.latitude;
    _pickedLng = u.longitude;
    _pickedPlaceId = u.placeId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Garage name is required')),
      );
      return;
    }
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required')),
      );
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone is required')),
      );
      return;
    }

    final updated = UserModel(
      id: widget.user.id,
      name: name,
      email: email,
      phone: phone,
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      latitude: _pickedLat,
      longitude: _pickedLng,
      placeId: _pickedPlaceId,
      services: widget.user.services,
      otherServices: widget.user.otherServices,
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
            const SnackBar(content: Text('Profile saved')),
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
          'Edit Profile',
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
              'Garage information',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AuthTextField(
              label: 'Garage name',
              controller: _nameController,
              hint: 'AutoCare Garage',
            ),
            const SizedBox(height: AppSpacing.md),
            AuthTextField(
              label: 'Phone',
              controller: _phoneController,
              hint: AuthConstants.phonePlaceholder,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.md),
            AuthTextField(
              label: 'Email',
              controller: _emailController,
              hint: 'contact@garage.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            LocationPickerField(
              label: 'Garage address',
              controller: _addressController,
              initialLat: _pickedLat,
              initialLng: _pickedLng,
              onLocationPicked: (loc) {
                setState(() {
                  _pickedLat = loc.latitude;
                  _pickedLng = loc.longitude;
                  _pickedPlaceId = loc.placeId;
                });
              },
              showMap: true,
              mapHeight: 180,
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
