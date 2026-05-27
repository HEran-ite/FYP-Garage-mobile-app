import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/error/user_friendly_errors.dart';
import '../../../../core/locale/l10n_extension.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_brand_logo.dart';
import '../../../../core/widgets/language_dropdown_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../test_support/test_keys.dart';
import '../widgets/auth_text_field.dart';

/// Login screen with CarCare branding, language dropdown, and localized copy.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
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
                SnackBar(
                  content: Text(
                    toUserFriendlyMessage(state.message, context.l10n),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthRestoringSession) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: AppSpacing.lg),
                    Text(context.l10n.loading),
                  ],
                ),
              );
            }
            return _LoginBody(isLoading: state is AuthLoginLoading);
          },
        ),
      ),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            right: AppSpacing.lg,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: const LanguageDropdownButton(),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                const Center(child: AppBrandLogo(width: 280)),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.loginWelcome,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.loginWelcomeSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _LoginFormCard(isLoading: isLoading),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.noAccount,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                      ),
                      InkWell(
                        key: TestKeys.loginCreateAccountLink,
                        onTap: () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthRegistrationStarted());
                          Navigator.of(context)
                              .pushNamed(RoutePaths.createAccount);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: AppSpacing.xs,
                          ),
                          child: Text(
                            l10n.createAccountLink,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginFormCard extends StatefulWidget {
  const _LoginFormCard({required this.isLoading});

  final bool isLoading;

  @override
  State<_LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<_LoginFormCard> {
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
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              key: TestKeys.loginEmail,
              label: l10n.email,
              hint: l10n.emailHint,
              prefixIcon: const Icon(
                Icons.mail_outline,
                color: AppColors.inputIcon,
              ),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              onCard: true,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.emailRequired : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthTextField(
              key: TestKeys.loginPassword,
              label: l10n.password,
              hint: l10n.passwordPlaceholder,
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.inputIcon,
              ),
              controller: _passwordController,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              onCard: true,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.passwordRequired : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              key: TestKeys.loginSubmit,
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
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryButtonText,
                      ),
                    )
                  : Text(
                      l10n.signIn,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
