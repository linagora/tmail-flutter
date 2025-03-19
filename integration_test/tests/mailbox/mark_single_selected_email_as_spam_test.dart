import '../../base/test_base.dart';
import '../../scenarios/mailbox/mark_single_selected_email_as_spam_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see selected email mark as spam successfully',
    scenarioBuilder: ($) => MarkSingleSelectedEmailAsSpamScenario($),
  );
}
