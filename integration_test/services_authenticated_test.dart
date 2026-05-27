/// Authenticated E2E — Services module (mocked backend)
///
/// Run: flutter test integration_test/services_authenticated_test.dart -d emulator-5554
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:garage/test_support/test_keys.dart';
import 'helpers/auth_mock_helpers.dart';
import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Services module (authenticated)', () {
    testWidgets('services tab shows garage offerings and saves', (tester) async {
      await bootAuthenticated(tester);
      expectAuthenticatedDashboard();

      await tapNavServices(tester);

      expect(find.text('Oil Change'), findsWidgets);
      expect(find.text('Brake Service'), findsWidgets);

      await tester.tap(find.byKey(TestKeys.servicesSave));
      await settleRoute(tester, cycles: 16);

      expect(find.text('Services saved'), findsOneWidget);

      await settleAfterInteraction(tester);
    });
  });
}
