import '../../base/test_base.dart';
import '../../scenarios/composer/change_identity_in_draft_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see new identity in From field when select new identity and save as draft successfully',
    scenarioBuilder: ($) => ChangeIdentityInDraftEmailScenario($),
  );
}