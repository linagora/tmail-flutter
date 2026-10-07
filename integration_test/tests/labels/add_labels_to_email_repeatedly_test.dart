import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/labels/add_labels_to_email_repeatedly_scenario.dart';

// The regression path is the add-label dialog: mobile, and narrow web layouts
// (run web with a narrow `--web-viewport`). The default desktop web run goes
// through the hover submenu instead, so there it is only a smoke test.
void main() {
  TestBase().runPatrolTest(
    description:
        'Should add every selected label to the opened email when labels are picked from the more menu repeatedly',
    scenarioBuilder: ($, robots) =>
        AddLabelsToEmailRepeatedlyScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
