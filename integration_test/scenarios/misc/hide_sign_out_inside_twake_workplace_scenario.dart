import '../../base/base_test_scenario.dart';
import '../../robots/web/web_workplace_profile_menu_robot.dart';
import '../../utils/twake_workplace_simulator.dart';

class HideSignOutInsideTwakeWorkplaceScenario extends BaseTestScenario {
  const HideSignOutInsideTwakeWorkplaceScenario(super.$, super.robots);

  @override
  Future<void> execute() async {
    // Before the seeded login opens the dashboard, which checks once whether
    // it runs inside Twake Workplace.
    simulateTwakeWorkplace();
    await super.execute();
  }

  @override
  Future<void> runTestLogic() async {
    await robots.commonRobot().waitForMailboxReady();

    final profileMenuRobot = WebWorkplaceProfileMenuRobot($);
    await profileMenuRobot.openProfileMenu();

    await profileMenuRobot.assertion.expectManageAccountVisible();
    await profileMenuRobot.assertion.expectSignOutHidden();
  }
}
