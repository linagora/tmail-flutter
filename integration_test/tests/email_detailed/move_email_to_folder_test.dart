import '../../base/test_base.dart';
import '../../scenarios/email_detailed/move_email_to_folder_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see email in destination folder when open detailed email and move email to destination folder successfully',
    scenarioBuilder: ($) => MoveEmailToFolderScenario($),
  );
}