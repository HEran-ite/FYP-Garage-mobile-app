import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/error/user_friendly_errors.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';

/// Login screen - email, password, sign in, and link to sign up.
/// On first build, dispatches [AuthRestoreSession] to restore session from SharedPreferences if present.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    // Restore session on next frame so SharedPreferences is ready (avoids channel-error on Android).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthRestoreSession());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoginSuccess) {
              Navigator.of(context).pushReplacementNamed(RoutePaths.dashboard);
            }
            if (state is AuthLoginError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(toUserFriendlyMessage(state.message))),
              );
            }
          },
          builder: (context, state) {
            // Don't show "Sign in" until we've checked saved session.
            if (state is AuthRestoringSession) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppSpacing.lg),
                    Text('Loading...'),
                  ],
                ),
              );
            }
            final isLoading = state is AuthLoginLoading;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _LoginForm(isLoading: isLoading),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.isLoading});

  final bool isLoading;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          _LogoHeader(),
          const SizedBox(height: AppSpacing.xxl),
          AuthTextField(
            label: 'Email',
            hint: 'you@example.com',
            prefixIcon: const Icon(Icons.mail_outline, color: AppColors.inputIcon),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (v) => v == null || v.trim().isEmpty ? 'Email is required' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthTextField(
            label: 'Password',
            hint: AuthConstants.passwordPlaceholder,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.inputIcon,
            ),
            controller: _passwordController,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            validator: (v) => v == null || v.isEmpty ? 'Password is required' : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: widget.isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryButtonText,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryButtonText,
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: RichText(
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                children: [
                  const TextSpan(text: "Don't have an account? "),
                  TextSpan(
                    text: 'Sign Up',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _navigateToCreateAccount(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateAccount(BuildContext context) {
    context.read<AuthBloc>().add(const AuthRegistrationStarted());
    Navigator.of(context).pushNamed(RoutePaths.createAccount);
  }
}

class _LogoHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accentIconBg,
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            border: Border.all(color: AppColors.accentIconBorder, width: 1),
          ),
          child: const Icon(
            Icons.build,
            size: 32,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Garage Owner',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Sign in to manage your services',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
