import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/open_email_link_after_sign_in_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should open a pasted delegated mailbox or Settings › Delegation link once signed in',
    scenarioBuilder: ($, robots) => OpenEmailLinkAfterSignInScenario($, robots),
    tags: [TestTags.web],
  );
}
