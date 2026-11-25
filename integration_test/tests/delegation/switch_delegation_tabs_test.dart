import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/switch_delegation_tabs_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should show who has access to my mailbox first, then the mailboxes delegated to me on the other tab',
    scenarioBuilder: ($, robots) => SwitchDelegationTabsScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
