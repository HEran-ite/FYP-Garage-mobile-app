/// E2E tests — Dashboard module
///
/// Run: flutter test integration_test/dashboard_test.dart -d emulator-5554
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:garage/core/routing/route_paths.dart';
import 'helpers/auth_mock_helpers.dart';
import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dashboard module', () {
    testWidgets('/dashboard route renders main shell when pushed from login', (
      tester,
    ) async {
      await bootToLogin(tester);
      await pushRoute(tester, RoutePaths.dashboard);
      await settleRoute(tester, cycles: 20);

      // Bottom nav labels render once each; the header "Dashboard" may also appear.
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Appointments'), findsWidgets);
      expect(find.text('Services'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);

      await settleAfterInteraction(tester);
    });
  });
}
