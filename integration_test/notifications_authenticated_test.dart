/// Authenticated E2E — Notifications module (mocked backend)
///
/// Run: flutter test integration_test/notifications_authenticated_test.dart -d emulator-5554
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:garage/features/notifications/presentation/pages/notifications_page.dart';
import 'helpers/auth_mock_helpers.dart';
import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notifications module (authenticated)', () {
    testWidgets('/notifications shows mock notification items', (
      tester,
    ) async {
      await bootAuthenticated(tester);
      expectAuthenticatedDashboard();

      await openNotificationsFromDashboard(tester);

      expect(find.byType(NotificationsPage), findsOneWidget);
      expect(find.text('New appointment request'), findsOneWidget);
      expect(find.text('Appointment approved'), findsOneWidget);

      await settleAfterInteraction(tester);
    });
  });
}
