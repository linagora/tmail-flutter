import '../robots/abstract/abstract_app_grid_robot.dart';
import '../robots/abstract/abstract_login_robot.dart';
import '../robots/abstract/abstract_thread_robot.dart';
import '../robots/abstract/abstract_composer_robot.dart';

abstract class RobotFactory {
  AbstractLoginRobot loginRobot();
  AbstractThreadRobot threadRobot();
  AbstractComposerRobot composerRobot();
  AbstractAppGridRobot appGridRobot();
}
