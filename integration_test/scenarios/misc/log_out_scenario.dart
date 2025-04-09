import 'package:tmail_ui_user/features/starting_page/presentation/twake_welcome/twake_welcome_view.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class LogOutScenario extends BaseTestScenario {
  const LogOutScenario(super.$);
  
  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);

    await threadRobot.openMailbox();
    await mailboxMenuRobot.tapManageAccount();
    await mailboxMenuRobot.tapSignOut();
    await mailboxMenuRobot.confirmSignOut();

    await _expectTwakeWelcomeViewVisible();
  }
  
  Future<void> _expectTwakeWelcomeViewVisible() async {
    await expectViewVisible($(TwakeWelcomeView));
  }
}