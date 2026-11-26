import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/remove_delegate_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should show the empty state when I remove my last delegate from the remove dialog',
    scenarioBuilder: ($, robots) => RemoveDelegateScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
