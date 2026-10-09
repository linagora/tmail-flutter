import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/labels/delete_open_label_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should go back to Inbox when deleting the open label',
    tags: [TestTags.android, TestTags.ios, TestTags.web],
    scenarioBuilder: ($, robots) => DeleteOpenLabelScenario($, robots),
  );
}
