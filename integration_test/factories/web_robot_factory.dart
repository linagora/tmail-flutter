import 'package:patrol/patrol.dart';

import '../robots/web/web_login_robot.dart';
import 'robot_factory.dart';
import '../robots/abstract/abstract_login_robot.dart';
import '../robots/abstract/abstract_thread_robot.dart';
import '../robots/abstract/abstract_composer_robot.dart';
import '../robots/mobile/mobile_thread_robot.dart';
import '../robots/web/web_composer_robot.dart';

class WebRobotFactory implements RobotFactory {
  final PatrolIntegrationTester $;

  WebRobotFactory(this.$);

  @override
  AbstractLoginRobot loginRobot() => WebLoginRobot($);

  @override
  // Thread interaction is identical on web — reuse mobile robot
  AbstractThreadRobot threadRobot() => MobileThreadRobot($);

  @override
  AbstractComposerRobot composerRobot() => WebComposerRobot($);
}
