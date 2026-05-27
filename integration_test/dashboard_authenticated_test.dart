/// Authenticated E2E — Dashboard module (mocked backend)
///
/// Run: flutter test integration_test/dashboard_authenticated_test.dart -d emulator-5554
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:garage/test_support/test_keys.dart';
import 'helpers/auth_mock_helpers.dart';
import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dashboard module (authenticated)', () {
    testWidgets('session boots with stats and tab navigation works', (
      tester,
    ) async {
      await bootAuthenticated(tester);

      expect(find.text("Today's Appointments"), findsOneWidget);
      expect(find.text('Pending Requests'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);

      await tapNavAppointments(tester);
      await settleRoute(tester, cycles: 16);
      expect(find.text('John Doe'), findsOneWidget);

      await tapNavServices(tester);
      await settleRoute(tester, cycles: 12);
      expect(find.textContaining('Oil Change'), findsWidgets);

      await tapNavProfile(tester);
      await settleRoute(tester, cycles: 12);
      expect(find.byKey(TestKeys.profileLogout), findsOneWidget);

      await tapNavDashboard(tester);
      await settleRoute(tester, cycles: 12);
      // "Dashboard" appears in the header AND the bottom nav.
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.byKey(TestKeys.navDashboard), findsOneWidget);

      await settleAfterInteraction(tester);
    });
  });
}
