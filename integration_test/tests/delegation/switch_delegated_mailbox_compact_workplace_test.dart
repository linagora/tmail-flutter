import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/switch_delegated_mailbox_compact_workplace_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should switch to a delegated mailbox and back from the compact chip when Workplace is narrower than desktop',
    scenarioBuilder: ($, robots) =>
        SwitchDelegatedMailboxCompactWorkplaceScenario($, robots),
    tags: [TestTags.web],
  );
}
