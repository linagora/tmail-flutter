import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/switch_delegated_mailbox_loading_dialog_standalone_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should show the account-switch loading dialog while opening a delegated mailbox',
    scenarioBuilder: ($, robots) =>
        SwitchDelegatedMailboxLoadingDialogStandaloneScenario($, robots),
    tags: [TestTags.web],
  );
}
