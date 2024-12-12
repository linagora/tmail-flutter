import '../../base/test_base.dart';
import '../../scenarios/app_grid_scenario.dart';
import '../../scenarios/login_with_basic_auth_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should display and navigate app grid correctly when clicked',
    test: ($) async {
      final loginWithBasicAuthScenario = LoginWithBasicAuthScenario($,
        username: const String.fromEnvironment('USERNAME'),
        hostUrl: const String.fromEnvironment('BASIC_AUTH_URL'),
        email: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
        password: const String.fromEnvironment('PASSWORD'),
      );

      final appGridScenario = AppGridScenario(
        $,
        loginWithBasicAuthScenario: loginWithBasicAuthScenario,
      );

      await appGridScenario.execute();
    }
  );
}