import '../../base/test_base.dart';
import '../../scenarios/login_with_basic_auth_scenario.dart';
import '../../scenarios/web_socket_update_ui_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see thread view updated per web socket message',
    test: ($) async {
      final loginWithBasicAuthScenario = LoginWithBasicAuthScenario($,
        username: const String.fromEnvironment('USERNAME'),
        hostUrl: const String.fromEnvironment('BASIC_AUTH_URL'),
        email: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
        password: const String.fromEnvironment('PASSWORD'),
      );

      final webSocketUpdateUiScenario = WebSocketUpdateUiScenario($,
        loginWithBasicAuthScenario: loginWithBasicAuthScenario,
        subject: 'web socket subject',
        content: 'web socket content',
      );

      await webSocketUpdateUiScenario.execute();
    }
  );
}