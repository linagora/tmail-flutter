import '../../base/base_test_scenario.dart';

class UnfocusSearchFieldWithEscapeScenario extends BaseTestScenario {
  const UnfocusSearchFieldWithEscapeScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    await robots.commonRobot().waitForMailboxReady();

    final searchRobot = robots.searchRobot();
    final keyboardRobot = robots.hardwareKeyboardRobot()!;

    await searchRobot.focusSearchField();

    await keyboardRobot.pressKey('Escape');

    await searchRobot.expectSearchFieldUnfocused();
  }
}
