import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/mailbox/touch_long_press_folder_on_mobile_web_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should open the folder menu on a touch long press in a phone-width browser',
    tags: [TestTags.web],
    scenarioBuilder: ($, robots) => TouchLongPressFolderOnMobileWebScenario($, robots),
  );
}
