import '../../base/test_base.dart';
import '../../scenarios/login_with_basic_auth_scenario.dart';
import '../../scenarios/no_disposition_inline_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see base64 inline image when attachment has no disposition but has cid',
    test: ($) async {
      final loginWithBasicAuthScenario = LoginWithBasicAuthScenario($,
        username: const String.fromEnvironment('USERNAME'),
        hostUrl: const String.fromEnvironment('BASIC_AUTH_URL'),
        email: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
        password: const String.fromEnvironment('PASSWORD'),
      );

      final noDispositionInlineScenario = NoDispositionInlineScenario($,
        loginWithBasicAuthScenario: loginWithBasicAuthScenario,
      );

      await noDispositionInlineScenario.execute();
    }
  );
}