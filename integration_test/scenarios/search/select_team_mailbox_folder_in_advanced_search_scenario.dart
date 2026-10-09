import '../../base/base_test_scenario.dart';
import '../../robots/destination_picker_robot.dart';

/// A team mailbox root only holds folders: tapping it in the advanced-search
/// folder picker expands it, and one of its folders becomes the search folder.
class SelectTeamMailboxFolderInAdvancedSearchScenario extends BaseTestScenario {
  const SelectTeamMailboxFolderInAdvancedSearchScenario(super.$, super.robots);

  static const teamMailboxName = 'bob-guests';

  @override
  Future<void> runTestLogic() async {
    final searchRobot = robots.searchRobot();
    final destinationPickerRobot = DestinationPickerRobot($);
    final teamMailboxRoot = destinationPickerRobot.folderByName(
      teamMailboxName,
    );

    await searchRobot.openSearch();
    await searchRobot.openAdvancedSearchFolderPicker();

    await destinationPickerRobot.scrollToFolder(teamMailboxRoot);
    await destinationPickerRobot.selectFolderByName(teamMailboxName);
    await destinationPickerRobot.assertion.expectFolderVisible(
      destinationPickerRobot.teamMailboxFolders(),
    );

    final folderName = await destinationPickerRobot
        .selectFirstTeamMailboxFolder();
    await destinationPickerRobot.assertion.expectPickerClosed();
    await searchRobot.expectAdvancedSearchFolder(folderName);
  }
}
