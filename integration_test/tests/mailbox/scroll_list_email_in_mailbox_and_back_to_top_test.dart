import '../../base/test_base.dart';
import '../../scenarios/mailbox/scroll_list_email_in_mailbox_and_back_to_top_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see back to top button when scroll list email in mailbox to bottom '
      'and not see back to top button when scroll list email to top',
    scenarioBuilder: ($) => ScrollListEmailInMailboxAndBackToTopScenario($),
  );
}