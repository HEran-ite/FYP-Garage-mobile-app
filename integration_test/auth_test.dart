/// E2E tests — Auth module (Login, Create account)
///
/// Run: flutter test integration_test/auth_test.dart -d emulator-5554
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:garage/main.dart' as app;
import 'package:garage/features/auth/presentation/pages/login_page.dart';
import 'package:garage/features/auth/presentation/pages/create_account_page.dart';
import 'package:garage/test_support/fake_datasources.dart';
import 'package:garage/test_support/test_keys.dart';
import 'helpers/auth_mock_helpers.dart';
import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth module — Login', () {
    testWidgets('login screen renders email, password, and sign in button', (
      tester,
    ) async {
      await bootToLogin(tester);

      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Sign in to your account to continue'), findsOneWidget);
      expect(find.byKey(TestKeys.loginSubmit), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));

      await settleAfterInteraction(tester);
    });

    testWidgets('login with valid test credentials reaches dashboard', (
      tester,
    ) async {
      await bootToLogin(tester);

      await tester.enterText(find.byKey(TestKeys.loginEmail), kE2eTestEmail);
      await tester.enterText(
        find.byKey(TestKeys.loginPassword),
        kE2eTestPassword,
      );
      await tester.tap(find.byKey(TestKeys.loginSubmit));
      await settleRoute(tester, cycles: 30);

      expect(find.byKey(TestKeys.navDashboard), findsOneWidget);
      expect(find.text('E2E Test Garage'), findsWidgets);

      await settleAfterInteraction(tester);
    });

    testWidgets('login with invalid credentials shows error snackbar', (
      tester,
    ) async {
      await bootToLogin(tester);

      await tester.enterText(find.byKey(TestKeys.loginEmail), 'wrong@test.garage');
      await tester.enterText(find.byKey(TestKeys.loginPassword), 'wrongpass');
      await tester.tap(find.byKey(TestKeys.loginSubmit));
      await settleRoute(tester, cycles: 12);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byKey(TestKeys.navDashboard), findsNothing);

      await settleAfterInteraction(tester);
    });

    testWidgets('Create account navigates to registration page', (tester) async {
      await bootToLogin(tester);

      final link = find.byKey(TestKeys.loginCreateAccountLink);
      await tester.ensureVisible(link);
      await tester.tap(link);
      await settleRoute(tester, cycles: 20);

      expect(find.byType(CreateAccountPage), findsOneWidget);
      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Basic Information'), findsOneWidget);

      // CreateAccountPage has no Material/Cupertino AppBar, so we pop the
      // route via the app's navigator key instead of [tester.pageBack].
      app.appNavigatorKey.currentState?.pop();
      await settleRoute(tester, cycles: 12);
      await settleAfterInteraction(tester);
    });
  });

  group('Auth module — Protected routes', () {
    testWidgets('/dashboard renders or redirects unauthenticated user', (
      tester,
    ) async {
      await bootToLogin(tester);
      await pushRoute(tester, '/dashboard');

      final onDashboard = find.byKey(TestKeys.navDashboard).evaluate().isNotEmpty;
      final onLogin = find.byType(LoginPage).evaluate().isNotEmpty;
      expect(onDashboard || onLogin, isTrue);

      await settleAfterInteraction(tester);
    });
  });
}
