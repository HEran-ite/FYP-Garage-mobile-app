/// Smoke test for E2E fake data sources.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:garage/test_support/fake_datasources.dart';

void main() {
  test('fake auth returns E2E test garage on valid login', () async {
    final auth = FakeAuthRemoteDataSource();
    final user = await auth.login(
      email: kE2eTestEmail,
      password: kE2eTestPassword,
    );
    expect(user.name, 'E2E Test Garage');
    expect(auth.authToken, isNotEmpty);
  });
}
