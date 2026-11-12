import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/web_url_names_shown_delegated_account_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should name the shown delegated account in the web URL and drop it back on my mailbox',
    scenarioBuilder: ($, robots) => WebUrlNamesShownDelegatedAccountScenario($, robots),
    tags: [TestTags.web],
  );
}
