import '../../base/base_test_scenario.dart';
import '../../robots/web/web_workplace_profile_menu_robot.dart';
import '../../utils/twake_workplace_simulator.dart';

class HideSignOutInsideTwakeWorkplaceScenario extends BaseTestScenario {
  const HideSignOutInsideTwakeWorkplaceScenario(super.$, super.robots);

  @override
  Future<void> prepare() async {
    // Before the seeded app mounts and the dashboard checks once whether it
    // runs inside Twake Workplace.
    simulateTwakeWorkplace();
    await super.prepare();
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
