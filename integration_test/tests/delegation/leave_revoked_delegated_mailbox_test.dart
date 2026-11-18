import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/leave_revoked_delegated_mailbox_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should show my mailbox with a warning when my access to the shown delegated mailbox ends',
    scenarioBuilder: ($, robots) => LeaveRevokedDelegatedMailboxScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
