import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';

import '../base/base_test_scenario.dart';

class AppGridScenario extends BaseTestScenario {
  const AppGridScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    try {
      PlatformInfo.isIntegrationTesting = true;
      final threadRobot = robots.threadRobot();
      final appGridRobot = robots.appGridRobot();

      await timedStep('expect_app_grid_icon', threadRobot.expectAppGridVisible);
      await timedStep('open_app_grid', threadRobot.openAppGrid);
      await timedStep('expect_app_count_initial', appGridRobot.expectAppCountAndLabelsMatch);
      await timedStep('expect_list_view', appGridRobot.expectListViewVisible);
      await timedStep('open_app_in_grid', appGridRobot.openAppInAppGrid);
      await timedStep('expect_app_count_after_open', appGridRobot.expectAppCountAndLabelsMatch);
    } finally {
      PlatformInfo.isIntegrationTesting = false;
    }
  }
}
