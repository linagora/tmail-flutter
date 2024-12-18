import '../../base/test_base.dart';
import '../../scenarios/forward_email_scenario.dart';
import '../../scenarios/login_with_basic_auth_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see HTML content contain enough: Subject, From, To, Cc, Bcc, Reply to',
    test: ($) async {
      final loginWithBasicAuthScenario = LoginWithBasicAuthScenario($,
        username: const String.fromEnvironment('USERNAME'),
        hostUrl: const String.fromEnvironment('BASIC_AUTH_URL'),
        email: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
        password: const String.fromEnvironment('PASSWORD'),
      );
      final forwardEmailScenario = ForwardEmailScenario(
        $,
        loginWithBasicAuthScenario: loginWithBasicAuthScenario,
      );

      await forwardEmailScenario.execute();
    },
  );
}