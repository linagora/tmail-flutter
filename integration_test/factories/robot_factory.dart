import '../robots/abstract/abstract_app_grid_robot.dart';
import '../robots/abstract/abstract_composer_robot.dart';
import '../robots/abstract/abstract_email_rules_setting_robot.dart';
import '../robots/abstract/abstract_login_robot.dart';
import '../robots/abstract/abstract_mailbox_menu_robot.dart';
import '../robots/abstract/abstract_rules_filter_creator_robot.dart';
import '../robots/abstract/abstract_thread_robot.dart';

abstract class RobotFactory {
  AbstractLoginRobot loginRobot();
  AbstractThreadRobot threadRobot();
  AbstractComposerRobot composerRobot();
  AbstractAppGridRobot appGridRobot();
  AbstractMailboxMenuRobot mailboxMenuRobot();
  AbstractRulesFilterCreatorRobot rulesFilterCreatorRobot();
  AbstractEmailRulesSettingRobot emailRulesSettingRobot();
}
