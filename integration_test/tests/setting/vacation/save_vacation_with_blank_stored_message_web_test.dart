import '../../../base/test_base.dart';
import '../../../models/test_tags.dart';
import '../../../scenarios/setting/vacation/save_vacation_with_blank_stored_message_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should show the empty message toast when saving an enabled vacation whose stored message is blank on web',
    scenarioBuilder: ($, robots) => SaveVacationWithBlankStoredMessageScenario($, robots),
    tags: [TestTags.web],
  );
}
