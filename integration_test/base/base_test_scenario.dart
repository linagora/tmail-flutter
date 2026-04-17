
import '../factories/robot_factory.dart';
import '../mixin/scenario_utils_mixin.dart';
import 'base_scenario.dart';

abstract class BaseTestScenario extends BaseScenario with ScenarioUtilsMixin {
  final RobotFactory robots;

  const BaseTestScenario(super.$, this.robots);

  @override
  Future<void> execute() async {
    await robots.loginRobot().loginWithBasicAuth(
      username: const String.fromEnvironment('USERNAME'),
      hostUrl: const String.fromEnvironment('BASIC_AUTH_URL'),
      email: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
      password: const String.fromEnvironment('PASSWORD'),
    );
    await runTestLogic();
  }

  Future<void> runTestLogic();
}
