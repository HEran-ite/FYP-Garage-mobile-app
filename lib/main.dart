import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/auth/jwt_expiry.dart';
import 'core/auth/session_invalidation.dart';
import 'core/locale/app_locale_scope.dart';
import 'core/locale/locale_service.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_paths.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/data/datasources/auth_session_storage.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'injection/injection_container.dart';

/// Global navigator so session invalidation clears the stack from any screen (e.g. dashboard).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

bool _hadAuthenticatedSession(AuthState state) =>
    state is AuthLoginSuccess ||
    state is AuthProfileUpdating ||
    state is AuthProfileUpdateError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env').catchError((_) {});

  // Fix blank map on Android: use Hybrid Composition and warm up Maps SDK
  if (defaultTargetPlatform == TargetPlatform.android) {
    final platform = GoogleMapsFlutterPlatform.instance;
    if (platform is GoogleMapsFlutterAndroid) {
      final android = platform;
      android.useAndroidViewSurface = true;
      android.warmup();
    }
  }

  await setupDependencyInjection();
  final prefs = await SharedPreferences.getInstance();
  final localeService = LocaleService(prefs);
  final hasSeenOnboarding = prefs.getBool(OnboardingPage.seenKey) ?? false;

  runApp(GarageUpApp(
    localeService: localeService,
    initialRoute:
        hasSeenOnboarding ? RoutePaths.login : RoutePaths.onboarding,
  ));
}

class GarageUpApp extends StatefulWidget {
  const GarageUpApp({
    super.key,
    required this.localeService,
    required this.initialRoute,
  });

  final LocaleService localeService;
  final String initialRoute;

  @override
  State<GarageUpApp> createState() => _GarageUpAppState();
}

class _GarageUpAppState extends State<GarageUpApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = resolveInitialLocale(widget.localeService);
  }

  Future<void> _setLocale(Locale locale) async {
    await widget.localeService.setLocale(locale);
    if (!mounted) return;
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      locale: _locale,
      setLocale: _setLocale,
      child: BlocProvider<AuthBloc>(
        create: (_) => sl<AuthBloc>(),
        child: _AuthRestoreWrapper(
          child: _AuthSessionShell(
            child: BlocListener<AuthBloc, AuthState>(
              listenWhen: (prev, curr) =>
                  curr is AuthInitial && _hadAuthenticatedSession(prev),
              listener: (context, state) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final nav = appNavigatorKey.currentState;
                  if (nav == null) return;
                  nav.pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      settings: const RouteSettings(name: RoutePaths.login),
                      builder: (_) => const LoginPage(),
                    ),
                    (_) => false,
                  );
                });
              },
              child: MaterialApp(
                navigatorKey: appNavigatorKey,
                title: 'CarCare',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                locale: _locale,
                supportedLocales: LocaleService.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                onGenerateRoute: AppRouter.onGenerateRoute,
                initialRoute: widget.initialRoute,
                debugShowCheckedModeBanner: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dispatches session restore on first frame so we recover auth state after hot restart or bloc recreation.
class _AuthRestoreWrapper extends StatefulWidget {
  const _AuthRestoreWrapper({required this.child});

  final Widget child;

  @override
  State<_AuthRestoreWrapper> createState() => _AuthRestoreWrapperState();
}

class _AuthRestoreWrapperState extends State<_AuthRestoreWrapper> {
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
  Widget build(BuildContext context) => widget.child;
}

/// Wires [sessionInvalidationNotifier] to [AuthBloc] and logs out on resume if the JWT is expired.
class _AuthSessionShell extends StatefulWidget {
  const _AuthSessionShell({required this.child});

  final Widget child;

  @override
  State<_AuthSessionShell> createState() => _AuthSessionShellState();
}

class _AuthSessionShellState extends State<_AuthSessionShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sessionInvalidationNotifier.onSessionExpired = _onSessionExpired;
  }

  @override
  void dispose() {
    sessionInvalidationNotifier.onSessionExpired = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onSessionExpired() {
    if (!mounted) return;
    context.read<AuthBloc>().add(const AuthSessionInvalidated());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkJwtOnResume();
    }
  }

  Future<void> _checkJwtOnResume() async {
    final session = await sl<AuthSessionStorage>().load();
    if (session == null || !mounted) return;
    if (JwtExpiry.isExpired(session.token) == true) {
      context.read<AuthBloc>().add(const AuthSessionInvalidated());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
