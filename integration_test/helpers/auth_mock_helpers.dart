/// Helpers for authenticated E2E tests with a mocked backend.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:garage/core/locale/locale_service.dart';
import 'package:garage/core/theme/app_theme.dart';
import 'package:garage/main.dart' as app;
import 'package:garage/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:garage/features/auth/data/datasources/auth_session_storage.dart';
import 'package:garage/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:garage/features/auth/presentation/pages/login_page.dart';
import 'package:garage/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:garage/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:garage/injection/injection_container.dart';
import 'package:garage/test_support/fake_datasources.dart';
/// Whether [app.main] has already been invoked in this test isolate.
bool garageAppLaunched = false;

bool _fontsPrepared = false;

/// Configures Google Fonts so the test emulator never tries to fetch over
/// the network. Without this, an offline emulator throws a
/// `SocketException: Failed host lookup: 'fonts.gstatic.com'` AFTER the test
/// has ended, which corrupts the binding state and causes subsequent tests to
/// fail with `!inTest` / `!_expectingFrame` assertions.
///
/// `disableGoogleFonts` makes [AppTheme] skip GoogleFonts entirely (the
/// `allowRuntimeFetching = false` switch alone still throws when the font is
/// not bundled as an asset).
Future<void> prepareIntegrationTestFonts() async {
  if (_fontsPrepared) return;
  AppTheme.disableGoogleFonts = true;
  GoogleFonts.config.allowRuntimeFetching = false;
  _fontsPrepared = true;
}

Future<void> _settleRoute(WidgetTester tester, {int cycles = 16}) async {
  for (var i = 0; i < cycles; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> ensureTestFakes() async {
  if (sl.isRegistered<AuthBloc>() && sl<AuthBloc>().isClosed) {
    // The previous test tore down the widget tree which closed our
    // lazySingleton blocs. Reset the locator so the next [app.main] call
    // gets fresh instances.
    await sl.reset();
  }
  if (!sl.isRegistered<AuthBloc>()) {
    await setupDependencyInjection(useTestFakes: true);
  }
}

/// Calls [app.main] when the widget tree hasn't been mounted yet, otherwise
/// reuses the existing tree. Avoids the `!inTest` binding crash that comes
/// from re-launching `app.main` while a previous test is still resolving.
Future<void> launchGarageAppIfNeeded(WidgetTester tester) async {
  await prepareIntegrationTestFonts();

  final hasMountedNavigator = app.appNavigatorKey.currentState != null;
  if (garageAppLaunched && hasMountedNavigator) {
    await ensureTestFakes();
    return;
  }

  // Tree was torn down (or never mounted) — make sure DI has fresh blocs
  // before we re-run app.main.
  await ensureTestFakes();

  app.main();
  garageAppLaunched = true;

  for (var i = 0; i < 60; i++) {
    await tester.pump(const Duration(milliseconds: 200));
    if (app.appNavigatorKey.currentState != null) break;
  }
}

/// Dismisses focus and waits for debounced timers before the next test ends.
///
/// IMPORTANT: do NOT await `GoogleFonts.pendingFonts()` here — when the
/// emulator has no network access the pending future never resolves and
/// "leaks" past the end of the test, putting the binding into an invalid
/// state for the next test.
Future<void> settleAfterInteraction(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> markOnboardingCompletedForAuth() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(OnboardingPage.seenKey, true);
}

/// Keeps E2E finders stable (English labels) regardless of emulator locale.
Future<void> ensureEnglishLocaleForE2e() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(LocaleService.localeKey, 'en');
}

Future<void> seedAuth() async {
  final token = testJwt();
  final user = kE2eTestUser;
  await sl<AuthSessionStorage>().save(token, user);
  sl<AuthRemoteDataSource>().setAuthToken(token);
}

Future<void> clearAuth() async {
  if (sl.isRegistered<AuthSessionStorage>()) {
    await sl<AuthSessionStorage>().clear();
  }
  if (sl.isRegistered<AuthRemoteDataSource>()) {
    sl<AuthRemoteDataSource>().clearAuthToken();
  }
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

/// Boots the app as an authenticated garage user with fake remote APIs.
Future<void> bootAuthenticated(WidgetTester tester) async {
  await ensureTestFakes();
  await clearAuth();
  await markOnboardingCompletedForAuth();
  await ensureEnglishLocaleForE2e();
  await seedAuth();
  await launchGarageAppIfNeeded(tester);

  for (var i = 0; i < 60; i++) {
    await tester.pump(const Duration(milliseconds: 200));
    if (find.byType(DashboardPage).evaluate().isNotEmpty) break;
  }

  expectAuthenticatedDashboard();
}

Future<void> pushRouteFromDashboard(WidgetTester tester, String route) async {
  NavigatorState? nav = app.appNavigatorKey.currentState;
  for (var i = 0; i < 50 && nav == null; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    nav = app.appNavigatorKey.currentState;
  }
  if (nav == null) {
    throw StateError(
      'appNavigatorKey.currentState was null; app failed to mount before pushRouteFromDashboard("$route")',
    );
  }
  nav.pushNamed(route);
  await _settleRoute(tester);
}

Future<void> popToDashboard(WidgetTester tester) async {
  final nav = app.appNavigatorKey.currentState!;
  while (nav.canPop()) {
    nav.pop();
    await _settleRoute(tester, cycles: 4);
  }
  expect(find.byType(DashboardPage), findsOneWidget);
}

/// JWT-shaped token with a far-future `exp` claim.
String testJwt() {
  String b64u(String json) =>
      base64Url.encode(utf8.encode(json)).replaceAll('=', '');
  final header = b64u('{"alg":"none","typ":"JWT"}');
  final payload = b64u(
    '{"exp":9999999999,"iat":1700000000,"sub":"garage-e2e-1"}',
  );
  return '$header.$payload.signature';
}

/// Asserts the app booted to dashboard, not login.
void expectAuthenticatedDashboard() {
  expect(find.byType(DashboardPage), findsOneWidget);
  expect(find.byType(LoginPage), findsNothing);
  expect(find.text('E2E Test Garage'), findsWidgets);
}
