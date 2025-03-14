import '../../base/test_base.dart';
import '../../scenarios/mailbox/scroll_mailbox_and_back_to_top_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see back to top button when scroll mailbox to bottom '
      'and not see back to top button when scroll mailbox to top',
    scenarioBuilder: ($) => ScrollMailboxAndBackToTopScenario($),
  );
}