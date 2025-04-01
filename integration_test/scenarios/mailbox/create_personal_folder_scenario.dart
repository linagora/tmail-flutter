import 'package:flutter_test/flutter_test.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class CreatePersonalFolderScenario extends BaseTestScenario {
  const CreatePersonalFolderScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const folderName = 'crud personal folder';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);

    await threadRobot.openMailbox();
    await mailboxMenuRobot.tapAddNewFolderButton();
    await mailboxMenuRobot.enterNewFolderName(folderName);
    await mailboxMenuRobot.confirmCreateNewFolder();
    await _expectMailboxWithNameVisible(folderName);
  }

  Future<void> _expectMailboxWithNameVisible(String name) async {
    await expectViewVisible($(name));
  }
}