import '../../base/test_base.dart';
import '../../scenarios/mailbox/create_personal_folder_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should create personal mailbox successfully',
    scenarioBuilder: ($) => CreatePersonalFolderScenario($),
  );
}