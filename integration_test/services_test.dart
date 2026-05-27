/// E2E tests — Services module
///
/// Run: flutter test integration_test/services_test.dart -d emulator-5554
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:garage/core/routing/route_paths.dart';
import 'package:garage/features/services/presentation/pages/service_list_page.dart';
import 'helpers/auth_mock_helpers.dart';
import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Services module', () {
    testWidgets('/services renders services page', (tester) async {
      await bootToLogin(tester);
      await pushRoute(tester, RoutePaths.services);

      expect(find.byType(ServiceListPage), findsOneWidget);

      await settleAfterInteraction(tester);
    });
  });
}
