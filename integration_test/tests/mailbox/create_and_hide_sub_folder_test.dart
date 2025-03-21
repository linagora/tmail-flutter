import '../../base/test_base.dart';
import '../../scenarios/mailbox/create_and_hide_sub_folder_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should create and hide sub folder successfully',
    scenarioBuilder: ($) => CreateAndHideSubFolderScenario($),
  );
}
