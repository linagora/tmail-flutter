import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/hide_my_account_offers_while_delegated_standalone_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should hide my vacation banner, Recover deleted messages and Create a rule when a delegated mailbox is shown',
    scenarioBuilder: ($, robots) =>
        HideMyAccountOffersWhileDelegatedStandaloneScenario($, robots),
    tags: [TestTags.web],
  );
}
