import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';

import '../base/base_test_scenario.dart';

class AppGridScenario extends BaseTestScenario {

  const AppGridScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    PlatformInfo.isIntegrationTesting = true;
    final threadRobot = robots.threadRobot();
    final appGridRobot = robots.appGridRobot();

    await threadRobot.expectAppGridVisible();
    await threadRobot.openAppGrid();

    await appGridRobot.expectListViewAppGridVisible();
    await appGridRobot.expectAllAppInAppGridDisplayedIsFull();

    await appGridRobot.openAppInAppGrid();
    
    await appGridRobot.expectListViewAppGridVisible();

    PlatformInfo.isIntegrationTesting = false;
  }
}