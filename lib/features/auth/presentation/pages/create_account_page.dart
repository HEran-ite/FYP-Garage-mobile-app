import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/error/user_friendly_errors.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/document_upload_button.dart';
import '../widgets/location_picker_field.dart';
import '../widgets/registration_stepper.dart';
import '../widgets/service_chip_grid.dart';

/// Create account flow: step 1 (basic info), step 2 (location & services), step 3 (verification)
class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistrationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(toUserFriendlyMessage(state.message))),
          );
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            _onBack(context, state);
          },
          child: Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _onBack(context, state),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Create Account'),
                Text(
                  'Step ${_currentStep(state) + 1} of ${AuthConstants.registrationStepCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),
          body: state is AuthRegistrationSuccess
              ? _buildStepContent(context, state)
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          RegistrationStepper(currentStep: _currentStep(state)),
                          const SizedBox(height: AppSpacing.lg),
                          ..._registrationStepChildren(state),
                        ],
                      ),
                    ),
                    if (state is AuthRegistrationSubmitting)
                      Positioned.fill(
                        child: AbsorbPointer(
                          child: ColoredBox(
                            color: Colors.black.withValues(alpha: 0.35),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
          ),
        );
      },
    );
  }

  int _currentStep(AuthState state) {
    if (state is AuthRegistrationStep1) return AuthConstants.stepBasicInfo;
    if (state is AuthRegistrationStep2) {
      return AuthConstants.stepLocationServices;
    }
    if (state is AuthRegistrationStep3 ||
        state is AuthRegistrationSubmitting ||
        (state is AuthRegistrationError &&
            state.step1Data != null &&
            state.step2Data != null)) {
      return AuthConstants.stepVerification;
    }
    return AuthConstants.stepBasicInfo;
  }

  List<Widget> _registrationStepChildren(AuthState state) {
    if (state is AuthRegistrationStep1) {
      return [_Step1Content(restore: state.restore)];
    }
    if (state is AuthRegistrationStep2) {
      return [
        _Step2Content(
          step1Data: state.step1Data,
          restoreStep2: state.restoreStep2,
        ),
      ];
    }
    RegistrationStep1Data? s1;
    RegistrationStep2Data? s2;
    if (state is AuthRegistrationStep3) {
      s1 = state.step1Data;
      s2 = state.step2Data;
    } else if (state is AuthRegistrationSubmitting) {
      s1 = state.step1Data;
      s2 = state.step2Data;
    } else if (state is AuthRegistrationError &&
        state.step1Data != null &&
        state.step2Data != null) {
      s1 = state.step1Data!;
      s2 = state.step2Data!;
    }
    if (s1 != null && s2 != null) {
      return [
        _Step3Content(
          key: const ValueKey<Object>('registration_step3_form'),
          step1Data: s1,
          step2Data: s2,
        ),
      ];
    }
    return [const SizedBox()];
  }

  void _onBack(BuildContext context, AuthState state) {
    if (state is AuthRegistrationSubmitting) {
      return;
    }
    if (state is AuthRegistrationStep1) {
      context.read<AuthBloc>().add(const AuthRegistrationCancelled());
      Navigator.of(context).pop();
      return;
    }
    if (state is AuthRegistrationStep2) {
      context.read<AuthBloc>().add(const AuthRegistrationStep2Back());
      return;
    }
    if (state is AuthRegistrationStep3) {
      context.read<AuthBloc>().add(const AuthRegistrationStep3Back());
      return;
    }
    if (state is AuthRegistrationError) {
      // If we kept step data, user is still on step 3 UI; allow back to step 2.
      if (state.step1Data != null && state.step2Data != null) {
        context.read<AuthBloc>().add(const AuthRegistrationStep3Back());
        return;
      }
      // Otherwise just exit registration.
      context.read<AuthBloc>().add(const AuthRegistrationCancelled());
      Navigator.of(context).pop();
      return;
    }
    if (state is AuthRegistrationSuccess) {
      context.read<AuthBloc>().add(const AuthRegistrationSuccessDismissed());
      Navigator.of(context).pop();
    }
  }

  Widget _buildStepContent(BuildContext context, AuthState state) {
    if (state is AuthRegistrationSuccess) {
      return _SubmissionSuccessModal(
        garageName: state.garageName,
        onGotIt: () {
          context.read<AuthBloc>().add(
            const AuthRegistrationSuccessDismissed(),
          );
          Navigator.of(context).pop();
        },
      );
    }
    return const SizedBox();
  }
}

class _Step1Content extends StatefulWidget {
  const _Step1Content({this.restore});

  final RegistrationStep1Data? restore;

  @override
  State<_Step1Content> createState() => _Step1ContentState();
}

class _Step1ContentState extends State<_Step1Content> {
  final _formKey = GlobalKey<FormState>();
  final _garageName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    final r = widget.restore;
    if (r != null) {
      _garageName.text = r.garageName;
      _phone.text = r.phone;
      _email.text = r.email;
      _password.text = r.password;
      _confirmPassword.text = r.confirmPassword;
    }
  }

  @override
  void dispose() {
    _garageName.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SectionHeader(
            icon: Icons.build,
            title: 'Basic Information',
            subtitle: 'Tell us about your garage',
            useSquareIcon: true,
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthTextField(
            label: 'Garage Name *',
            controller: _garageName,
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            maxLength: AuthConstants.maxGarageNameLength,
            prefixIcon: const Icon(Icons.business, color: AppColors.inputIcon),
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthTextField(
            label: 'Phone Number *',
            hint: AuthConstants.phonePlaceholder,
            controller: _phone,
            keyboardType: TextInputType.phone,
            validator: AuthConstants.validateEthiopianPhone,
            maxLength: AuthConstants.maxPhoneLength,
            prefixIcon: const Icon(Icons.call, color: AppColors.inputIcon),
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthTextField(
            label: 'Email Address *',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            maxLength: AuthConstants.maxEmailLength,
            prefixIcon: const Icon(
              Icons.mail_outline,
              color: AppColors.inputIcon,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthTextField(
            label: 'Password *',
            hint: AuthConstants.passwordPlaceholder,
            controller: _password,
            obscureText: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v.length < AuthConstants.minPasswordLength) {
                return 'At least ${AuthConstants.minPasswordLength} characters';
              }
              return null;
            },
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.inputIcon,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthTextField(
            label: 'Confirm Password *',
            hint: AuthConstants.confirmPasswordPlaceholder,
            controller: _confirmPassword,
            obscureText: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v != _password.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                context.read<AuthBloc>().add(
                  AuthRegistrationStep1Next(
                    garageName: _garageName.text.trim(),
                    phone: _phone.text.trim(),
                    email: _email.text.trim(),
                    password: _password.text,
                    confirmPassword: _confirmPassword.text,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryButtonText,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _Step2Content extends StatefulWidget {
  const _Step2Content({
    required this.step1Data,
    this.restoreStep2,
  });

  final RegistrationStep1Data step1Data;
  final RegistrationStep2Data? restoreStep2;

  @override
  State<_Step2Content> createState() => _Step2ContentState();
}

class _Step2ContentState extends State<_Step2Content> {
  final _addressController = TextEditingController();
  List<String> _selectedServices = [];
  List<String> _customServiceNames = [];
  double? _pickedLat;
  double? _pickedLng;
  String? _pickedPlaceId;

  @override
  void initState() {
    super.initState();
    final r = widget.restoreStep2;
    if (r != null) {
      _addressController.text = r.address;
      _selectedServices = List<String>.from(r.services);
      if (r.otherServices != null && r.otherServices!.trim().isNotEmpty) {
        _customServiceNames = r.otherServices!
            .split(RegExp(r',\s*'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      _pickedLat = r.latitude;
      _pickedLng = r.longitude;
      _pickedPlaceId = r.placeId;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          icon: Icons.location_on_outlined,
          title: 'Location & Services',
          subtitle: 'Where are you located and what do you offer?',
          useSquareIcon: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        LocationPickerField(
          label: 'Garage Address *',
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
          mapHeight: 160,
        ),
        if (_pickedLat == null || _pickedLng == null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              AuthConstants.mapSetExactLocationHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Services Offered *',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          '${_selectedServices.length + _customServiceNames.length} selected',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        ServiceChipGrid(
          selectedServices: _selectedServices,
          onSelectionChanged: (v) => setState(() => _selectedServices = v),
          customServiceNames: _customServiceNames,
          onCustomServiceNamesChanged: (v) => setState(() => _customServiceNames = v),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.read<AuthBloc>().add(
                  const AuthRegistrationStep2Back(),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.stepperInactive),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: (_selectedServices.isEmpty && _customServiceNames.isEmpty) ||
                        _pickedLat == null ||
                        _pickedLng == null
                    ? null
                    : () {
                        if (_addressController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                AuthConstants.addressRequiredMessage,
                              ),
                            ),
                          );
                          return;
                        }
                        if (_pickedLat == null || _pickedLng == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                AuthConstants.locationRequiredMessage,
                              ),
                            ),
                          );
                          return;
                        }
                        context.read<AuthBloc>().add(
                          AuthRegistrationStep2Next(
                            address: _addressController.text.trim(),
                            services: _selectedServices,
                            otherServices: _customServiceNames.isEmpty
                                ? null
                                : _customServiceNames.join(', '),
                            latitude: _pickedLat,
                            longitude: _pickedLng,
                            placeId: _pickedPlaceId,
                          ),
                        );
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.5,
                  ),
                  foregroundColor: AppColors.primaryButtonText,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _Step3Content extends StatefulWidget {
  const _Step3Content({
    super.key,
    required this.step1Data,
    required this.step2Data,
  });

  final RegistrationStep1Data step1Data;
  final RegistrationStep2Data step2Data;

  @override
  State<_Step3Content> createState() => _Step3ContentState();
}

class _Step3ContentState extends State<_Step3Content> {
  String? _documentPath;
  Uint8List? _documentBytes;
  String? _documentFileName;

  bool get _hasDocument => (_documentBytes != null && _documentBytes!.isNotEmpty) ||
      (_documentPath != null && _documentPath!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          icon: Icons.upload_file,
          title: 'Verification',
          subtitle: 'Upload your business documents',
          useSquareIcon: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('Business License *'),
        const SizedBox(height: AppSpacing.sm),
        DocumentUploadButton(
          filePath: _documentFileName ?? _documentPath,
          onTap: () async {
            try {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                withData: true,
              );
              if (!mounted) return;
              if (result != null && result.files.isNotEmpty) {
                final file = result.files.first;
                setState(() {
                  _documentBytes = file.bytes;
                  _documentFileName = file.name;
                  _documentPath = file.path;
                });
              }
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Unable to open file picker. ${toUserFriendlyMessage(e.toString())}',
                  ),
                ),
              );
            }
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Review Your Information',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ReviewRow(label: 'Garage Name', value: widget.step1Data.garageName),
        _ReviewRow(label: 'Phone', value: widget.step1Data.phone),
        _ReviewRow(label: 'Email', value: widget.step1Data.email),
        _ReviewRow(
          label: 'Services',
          value: () {
            final extra = widget.step2Data.otherServices
                    ?.split(RegExp(r',\s*'))
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .length ??
                0;
            return '${widget.step2Data.services.length + extra} selected';
          }(),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          "Almost done! Your application will be reviewed within ${AuthConstants.expectedApprovalTime}. You'll receive an email as soon as it's approved.",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.read<AuthBloc>().add(
                  const AuthRegistrationStep3Back(),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.stepperInactive),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  if (!_hasDocument) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please upload your business license (PDF, PNG or JPG)',
                        ),
                      ),
                    );
                    return;
                  }
                  context.read<AuthBloc>().add(
                    AuthRegistrationSubmitted(
                      businessLicensePath: _documentPath,
                      businessLicenseBytes: _documentBytes,
                      businessLicenseFileName: _documentFileName,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryButtonText,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                child: const Text('Submit Application'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.useSquareIcon = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool useSquareIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentIconBg,
              shape: useSquareIcon ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: useSquareIcon
                  ? BorderRadius.circular(AppBorderRadius.sm)
                  : null,
              border: Border.all(color: AppColors.accentIconBorder, width: 1),
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _SubmissionSuccessModal extends StatelessWidget {
  const _SubmissionSuccessModal({
    required this.garageName,
    required this.onGotIt,
  });

  final String garageName;
  final VoidCallback onGotIt;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(color: Colors.black26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.successCheck,
                  child: Icon(Icons.check, color: Colors.white, size: 48),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Application Submitted!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Thank you for registering, $garageName! Your application is now under review. Once approved by our admin team, your garage will appear on the driver\'s map and you can start receiving service requests.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Expected approval time: ${AuthConstants.expectedApprovalTime}. You\'ll receive an email as a notification once your account is approved.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onGotIt,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryButtonText,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                    ),
                    child: const Text('Got It'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
