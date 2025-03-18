import '../../base/test_base.dart';
import '../../scenarios/mailbox/mailbox_count_real_time_update_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see mailbox unread count update real time',
    scenarioBuilder: ($) => MailboxCountRealTimeUpdateScenario($),
  );
}
