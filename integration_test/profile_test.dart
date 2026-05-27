/// E2E tests — Profile module
///
/// Run: flutter test integration_test/profile_test.dart -d emulator-5554
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:garage/core/routing/route_paths.dart';
import 'package:garage/features/profile/presentation/pages/profile_page.dart';
import 'helpers/auth_mock_helpers.dart';
import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Profile module', () {
    testWidgets('/profile renders profile page shell', (tester) async {
      await bootToLogin(tester);
      await pushRoute(tester, RoutePaths.profile);

      expect(find.byType(ProfilePage), findsOneWidget);

      await settleAfterInteraction(tester);
    });
  });
}
