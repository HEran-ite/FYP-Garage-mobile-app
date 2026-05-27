/// E2E tests — Notifications module
///
/// Run: flutter test integration_test/notifications_test.dart -d emulator-5554
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:garage/core/routing/route_paths.dart';
import 'package:garage/features/notifications/presentation/pages/notifications_page.dart';
import 'helpers/auth_mock_helpers.dart';
import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notifications module', () {
    testWidgets('/notifications renders notifications page', (tester) async {
      await bootToLogin(tester);
      await pushRoute(tester, RoutePaths.notifications);

      expect(find.byType(NotificationsPage), findsOneWidget);
      expect(find.text('Notifications'), findsWidgets);

      await settleAfterInteraction(tester);
    });
  });
}
