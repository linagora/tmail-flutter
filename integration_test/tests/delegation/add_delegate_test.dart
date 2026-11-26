import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/add_delegate_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should list a new delegate when I give them access from the add dialog',
    scenarioBuilder: ($, robots) => AddDelegateScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
