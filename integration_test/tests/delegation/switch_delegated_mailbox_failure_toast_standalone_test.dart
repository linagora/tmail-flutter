import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/switch_delegated_mailbox_failure_toast_standalone_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        "Should toast Couldn't open owner's mailbox when the switch is cancelled",
    scenarioBuilder: ($, robots) =>
        SwitchDelegatedMailboxFailureToastStandaloneScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
