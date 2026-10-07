import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/labels/add_labels_to_email_repeatedly_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should add every selected label to the opened email when labels are picked from the more menu repeatedly',
    scenarioBuilder: ($, robots) =>
        AddLabelsToEmailRepeatedlyScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
