import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/refresh_delegated_to_me_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should update the account switcher from Settings › With me when the owner revokes and grants access again',
    scenarioBuilder: ($, robots) => RefreshDelegatedToMeScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
