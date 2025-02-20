import '../base/base_scenario.dart';
import '../scenarios/login_with_basic_auth_scenario.dart';

mixin RequiresLoginMixin on BaseScenario {
  Future<void> executeLoginScenario() async {
    final loginScenario = LoginWithBasicAuthScenario(
      $,
      username: const String.fromEnvironment('USERNAME'),
      hostUrl: const String.fromEnvironment('BASIC_AUTH_URL'),
      email: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
      password: const String.fromEnvironment('PASSWORD'),
    );
    await loginScenario.execute();
  }
}