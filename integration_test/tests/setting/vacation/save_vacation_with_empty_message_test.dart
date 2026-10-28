import '../../../base/test_base.dart';
import '../../../models/test_tags.dart';
import '../../../scenarios/setting/vacation/save_vacation_with_empty_message_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should show the empty message toast and save nothing when saving an enabled vacation with an empty message',
    scenarioBuilder: ($, robots) => SaveVacationWithEmptyMessageScenario($, robots),
    tags: [TestTags.android, TestTags.ios],
  );
}
