import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/login_with_basic_auth_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see thread view when login with basic auth successfully',
    scenarioBuilder: ($, robots) => LoginWithBasicAuthScenario(
      $,
      robots,
      username: const String.fromEnvironment('USERNAME'),
      hostUrl: const String.fromEnvironment('BASIC_AUTH_URL'),
      email: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
      password: const String.fromEnvironment('PASSWORD'),
    ),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}