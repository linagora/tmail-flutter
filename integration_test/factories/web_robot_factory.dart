import 'package:patrol/patrol.dart';

import '../robots/abstract/abstract_app_grid_robot.dart';
import '../robots/web/web_app_grid_robot.dart';
import '../robots/web/web_login_robot.dart';
import '../robots/web/web_thread_robot.dart';
import 'robot_factory.dart';
import '../robots/abstract/abstract_login_robot.dart';
import '../robots/abstract/abstract_thread_robot.dart';
import '../robots/abstract/abstract_composer_robot.dart';
import '../robots/web/web_composer_robot.dart';

class WebRobotFactory implements RobotFactory {
  final PatrolIntegrationTester $;

  WebRobotFactory(this.$);

  @override
  AbstractLoginRobot loginRobot() => WebLoginRobot($);

  @override
  AbstractThreadRobot threadRobot() => WebThreadRobot($);

  @override
  AbstractComposerRobot composerRobot() => WebComposerRobot($);

  @override
  AbstractAppGridRobot appGridRobot() => WebAppGridRobot($);
}
