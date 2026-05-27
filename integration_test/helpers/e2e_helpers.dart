/// Shared helpers for CarCare Garage end-to-end integration tests.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:garage/main.dart' as app;
import 'package:garage/core/routing/route_paths.dart';
import 'package:garage/features/auth/presentation/pages/login_page.dart';
import 'package:garage/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:garage/test_support/test_keys.dart';

import 'auth_mock_helpers.dart'
    show
        ensureTestFakes,
        garageAppLaunched,
        launchGarageAppIfNeeded,
        clearAuth,
        settleAfterInteraction,
        ensureEnglishLocaleForE2e;

/// Boots the app and pumps until the initial UI has settled.
Future<void> bootApp(WidgetTester tester, {int pumpCycles = 40}) async {
  await launchGarageAppIfNeeded(tester);
  if (pumpCycles > 0 && garageAppLaunched) {
    for (var i = 0; i < pumpCycles; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }
}

/// Pumps long enough for a route push + page initState + first async work.
Future<void> settleRoute(WidgetTester tester, {int cycles = 16}) async {
  for (var i = 0; i < cycles; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> markOnboardingCompleted({required bool completed}) async {
  final prefs = await SharedPreferences.getInstance();
  if (completed) {
    await prefs.setBool(OnboardingPage.seenKey, true);
  } else {
    await prefs.remove(OnboardingPage.seenKey);
  }
}

/// Returns to [LoginPage] without calling [app.main] again.
Future<void> ensureOnLoginScreen(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byType(LoginPage).evaluate().isNotEmpty) return;
  }

  final nav = app.appNavigatorKey.currentState;
  if (nav != null) {
    while (nav.canPop()) {
      nav.pop();
      await settleRoute(tester, cycles: 4);
    }
  }

  if (find.byKey(TestKeys.navDashboard).evaluate().isNotEmpty) {
    await tapNavProfile(tester);
    final logout = find.byKey(TestKeys.profileLogout);
    final scrollables = find.byType(Scrollable).evaluate();
    if (logout.evaluate().isEmpty && scrollables.isNotEmpty) {
      await tester.scrollUntilVisible(
        logout,
        120,
        scrollable: find.byType(Scrollable).last,
      );
    }
    if (logout.evaluate().isNotEmpty) {
      await tester.tap(logout);
      await settleRoute(tester, cycles: 24);
    }
  }

  await settleAfterInteraction(tester);
}

/// Boots straight to the Login page (onboarding skipped, no auth token).
Future<void> bootToLogin(WidgetTester tester) async {
  await ensureTestFakes();
  await clearAuth();
  await markOnboardingCompleted(completed: true);
  await ensureEnglishLocaleForE2e();

  // [launchGarageAppIfNeeded] is a no-op when the previous test left the app
  // mounted on LoginPage; otherwise (binding torn down between tests) it
  // re-runs [app.main] so the widget tree is rebuilt.
  await launchGarageAppIfNeeded(tester);
  for (var i = 0; i < 60; i++) {
    await tester.pump(const Duration(milliseconds: 200));
    if (find.byType(LoginPage).evaluate().isNotEmpty) break;
  }
  if (find.byType(LoginPage).evaluate().isEmpty) {
    await ensureOnLoginScreen(tester);
  }

  expect(
    find.byType(LoginPage),
    findsOneWidget,
    reason: 'expected to land on LoginPage after onboarding/auth-check',
  );
}

Future<void> pushRoute(
  WidgetTester tester,
  String route, {
  Object? arguments,
}) async {
  NavigatorState? nav = app.appNavigatorKey.currentState;
  for (var i = 0; i < 50 && nav == null; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    nav = app.appNavigatorKey.currentState;
  }
  if (nav == null) {
    throw StateError(
      'appNavigatorKey.currentState was null; app failed to mount before pushRoute("$route")',
    );
  }
  nav.pushNamed(route, arguments: arguments);
  await settleRoute(tester);
}

Future<void> popToLogin(WidgetTester tester) async {
  final nav = app.appNavigatorKey.currentState!;
  while (nav.canPop()) {
    nav.pop();
    await settleRoute(tester, cycles: 4);
  }
  expect(find.byType(LoginPage), findsOneWidget);
}

/// Garage dashboard uses bottom tabs; tap by key to avoid duplicate text matches.
Future<void> _tapNavByKey(WidgetTester tester, Key key) async {
  await tester.tap(find.byKey(key));
  await settleRoute(tester);
}

Future<void> tapNavDashboard(WidgetTester tester) =>
    _tapNavByKey(tester, TestKeys.navDashboard);

Future<void> tapNavAppointments(WidgetTester tester) =>
    _tapNavByKey(tester, TestKeys.navAppointments);

Future<void> tapNavServices(WidgetTester tester) =>
    _tapNavByKey(tester, TestKeys.navServices);

Future<void> tapNavProfile(WidgetTester tester) =>
    _tapNavByKey(tester, TestKeys.navProfile);

/// Push notifications from dashboard header (requires authenticated dashboard).
Future<void> openNotificationsFromDashboard(WidgetTester tester) async {
  await pushRoute(tester, RoutePaths.notifications);
}
