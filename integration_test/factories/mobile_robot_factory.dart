import 'package:patrol/patrol.dart';

import '../robots/abstract/abstract_app_grid_robot.dart';
import '../robots/abstract/abstract_composer_robot.dart';
import '../robots/abstract/abstract_email_rules_setting_robot.dart';
import '../robots/abstract/abstract_login_robot.dart';
import '../robots/abstract/abstract_mailbox_menu_robot.dart';
import '../robots/abstract/abstract_rules_filter_creator_robot.dart';
import '../robots/abstract/abstract_thread_robot.dart';
import '../robots/mobile/mobile_app_grid_robot.dart';
import '../robots/mobile/mobile_composer_robot.dart';
import '../robots/mobile/mobile_email_rules_setting_robot.dart';
import '../robots/mobile/mobile_login_robot.dart';
import '../robots/mobile/mobile_mailbox_menu_robot.dart';
import '../robots/mobile/mobile_rules_filter_creator_robot.dart';
import '../robots/mobile/mobile_thread_robot.dart';
import 'robot_factory.dart';

class MobileRobotFactory implements RobotFactory {
  final PatrolIntegrationTester $;

  MobileRobotFactory(this.$);

  @override
  AbstractLoginRobot loginRobot() => MobileLoginRobot($);

  @override
  AbstractThreadRobot threadRobot() => MobileThreadRobot($);

  @override
  AbstractComposerRobot composerRobot() => MobileComposerRobot($);

  @override
  AbstractAppGridRobot appGridRobot() => MobileAppGridRobot($);

  @override
  AbstractMailboxMenuRobot mailboxMenuRobot() => MobileMailboxMenuRobot($);

  @override
  AbstractRulesFilterCreatorRobot rulesFilterCreatorRobot() => MobileRulesFilterCreatorRobot($);

  @override
  AbstractEmailRulesSettingRobot emailRulesSettingRobot() => MobileEmailRulesSettingRobot($);
}
