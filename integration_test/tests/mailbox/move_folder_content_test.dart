import '../../base/test_base.dart';
import '../../scenarios/mailbox/move_folder_content_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see all Inbox emails in the Templates folder when perform move folder content action successfully',
    scenarioBuilder: ($) => MoveFolderContentScenario($),
  );
}
