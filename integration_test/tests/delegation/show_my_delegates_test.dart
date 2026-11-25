import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/show_my_delegates_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should list everyone who has access to my mailbox with the add button below',
    scenarioBuilder: ($, robots) => ShowMyDelegatesScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
