import '../../base/base_test_scenario.dart';

class CreatePersonalFolderScenario extends BaseTestScenario {
  const CreatePersonalFolderScenario(super.$, super.robots);

  static const _folderName = 'crud personal folder';

  @override
  Future<void> runTestLogic() async {
    final threadRobot = robots.threadRobot();
    final mailboxMenuRobot = robots.mailboxMenuRobot();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.folder.tapAddNewFolderButton();
    await mailboxMenuRobot.folder.enterNewFolderName(_folderName);
    await mailboxMenuRobot.folder.confirmCreateNewFolder();
    await mailboxMenuRobot.assertion.expectMailboxVisible(mailboxMenuRobot.mailboxItemByName(_folderName));
  }
}
