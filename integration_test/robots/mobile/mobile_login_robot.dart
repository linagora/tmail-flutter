import 'package:patrol/patrol.dart';

import '../abstract/abstract_login_robot.dart';
import '../../scenarios/login_with_basic_auth_scenario.dart';

class MobileLoginRobot implements AbstractLoginRobot {
  final PatrolIntegrationTester $;

  MobileLoginRobot(this.$);

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
