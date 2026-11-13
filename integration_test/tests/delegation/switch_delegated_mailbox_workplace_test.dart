import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/switch_delegated_mailbox_workplace_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should switch to a delegated mailbox from the Workplace chip, compose as the owner, and switch back',
    scenarioBuilder: ($, robots) =>
        SwitchDelegatedMailboxWorkplaceScenario($, robots),
    tags: [TestTags.web],
  );
}
