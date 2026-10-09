import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/labels/rename_open_label_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should keep the label open when renaming the open label',
    tags: [TestTags.android, TestTags.ios, TestTags.web],
    scenarioBuilder: ($, robots) => RenameOpenLabelScenario($, robots),
  );
}
