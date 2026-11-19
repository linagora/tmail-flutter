import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/remove_my_access_to_delegated_mailbox_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should drop a delegated mailbox from Settings and the switcher when I remove my access',
    scenarioBuilder: ($, robots) =>
        RemoveMyAccessToDelegatedMailboxScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
