import 'package:patrol/patrol.dart';

import '../../scenarios/web_login_with_basic_auth_scenario.dart';
import '../abstract/abstract_login_robot.dart';

class WebLoginRobot implements AbstractLoginRobot {
  final PatrolIntegrationTester $;

  WebLoginRobot(this.$);

  @override
  Future<void> loginWithBasicAuth({
    required String username,
    required String hostUrl,
    required String email,
    required String password,
  }) async {
    await LoginWithBasicAuthScenario(
      $,
      username: username,
      hostUrl: hostUrl,
      email: email,
      password: password,
    ).execute();
  }
}
