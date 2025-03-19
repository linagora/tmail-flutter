import '../../base/test_base.dart';
import '../../scenarios/mailbox/mark_single_selected_email_as_read_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see selected email mark as read successfully',
    scenarioBuilder: ($) => MarkSingleSelectedEmailAsReadScenario($),
  );
}
