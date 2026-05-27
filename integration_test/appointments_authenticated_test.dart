/// Authenticated E2E — Appointments module (mocked backend)
///
/// Run: flutter test integration_test/appointments_authenticated_test.dart -d emulator-5554
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:garage/test_support/test_keys.dart';
import 'helpers/auth_mock_helpers.dart';
import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Appointments module (authenticated)', () {
    testWidgets('lists, filters, and searches mock appointments', (
      tester,
    ) async {
      await bootAuthenticated(tester);
      await tapNavAppointments(tester);
      await settleRoute(tester, cycles: 20);

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      // Service row is "Oil Change • At Garage", not a standalone label.
      expect(find.textContaining('Oil Change'), findsWidgets);

      await tester.tap(find.byKey(TestKeys.appointmentFilterPending));
      await settleRoute(tester, cycles: 12);

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsNothing);

      await tester.tap(find.byKey(TestKeys.appointmentFilterAll));
      await settleRoute(tester, cycles: 12);

      await tester.enterText(find.byKey(TestKeys.appointmentSearch), 'Jane');
      await settleRoute(tester, cycles: 24);

      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('John Doe'), findsNothing);

      await settleAfterInteraction(tester);
    });
  });
}
