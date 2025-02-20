import '../../base/test_base.dart';
import '../../scenarios/login_with_basic_auth_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see thread view when login with basic auth successfully',
    scenarioBuilder: ($) => LoginWithBasicAuthScenario(
      $,
      username: const String.fromEnvironment('USERNAME'),
      hostUrl: const String.fromEnvironment('BASIC_AUTH_URL'),
      email: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
      password: const String.fromEnvironment('PASSWORD'),
    ),
  );
}