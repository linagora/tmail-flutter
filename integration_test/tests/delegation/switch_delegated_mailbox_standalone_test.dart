import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/switch_delegated_mailbox_standalone_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should switch to a delegated mailbox from the stand-alone avatar menu',
    scenarioBuilder: ($, robots) =>
        SwitchDelegatedMailboxStandaloneScenario($, robots),
    tags: [TestTags.web],
  );
}
