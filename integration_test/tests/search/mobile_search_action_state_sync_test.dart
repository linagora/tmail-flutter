import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/mobile_search_action_state_sync_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should update Search results immediately when selected emails are marked read and archived',
    scenarioBuilder: ($, robots) =>
        MobileSearchActionStateSyncScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
