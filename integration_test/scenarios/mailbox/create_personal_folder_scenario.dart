import '../../base/base_test_scenario.dart';
import '../../utils/wait_for_condition.dart';

class CreatePersonalFolderScenario extends BaseTestScenario {
  const CreatePersonalFolderScenario(super.$, super.robots);

  static const _folderName = 'crud personal folder';

  @override
  Future<void> runTestLogic() async {
    final threadRobot = robots.threadRobot();
    final mailboxMenuRobot = robots.mailboxMenuRobot();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.tapAddNewFolderButton();
    await mailboxMenuRobot.enterNewFolderName(_folderName);
    await mailboxMenuRobot.confirmCreateNewFolder();

    await _expectMailboxWithNameVisible(_folderName);
  }

  Future<void> _expectMailboxWithNameVisible(String name) async {
    // waitForCondition yields to the browser event loop between retries (via
    // Future.delayed), allowing the JMAP Mailbox/set response to arrive on web.
    await waitForCondition(
      () async => $(name).evaluate().isNotEmpty,
    );
    await expectViewVisible($(name));
  }
}
