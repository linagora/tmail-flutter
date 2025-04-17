import '../../base/test_base.dart';
import '../../scenarios/email_detailed/forwarding_email_lost_attachments_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see attachment list in email view after forward email successfully',
    scenarioBuilder: ($) => ForwardingEmailLostAttachmentsScenario($),
  );
}