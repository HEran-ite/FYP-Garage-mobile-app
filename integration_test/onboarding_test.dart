/// E2E tests — Onboarding module (Skip flow)
///
/// Run: flutter test integration_test/onboarding_test.dart -d emulator-5554
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:garage/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:garage/features/auth/presentation/pages/login_page.dart';
import 'helpers/auth_mock_helpers.dart';
import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding module', () {
    testWidgets('first launch shows onboarding and Skip leads to login', (
      tester,
    ) async {
      await markOnboardingCompleted(completed: false);
      await launchGarageAppIfNeeded(tester);

      expect(find.byType(OnboardingPage), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await settleRoute(tester, cycles: 20);

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Welcome'), findsOneWidget);

      await settleAfterInteraction(tester);
    });
  });
}
