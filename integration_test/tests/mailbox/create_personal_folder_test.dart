import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/mailbox/create_personal_folder_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should create personal mailbox successfully',
    scenarioBuilder: ($, robots) => CreatePersonalFolderScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
