import '../../../base/test_base.dart';
import '../../../models/test_tags.dart';
import '../../../scenarios/setting/preferences/toggle_delegation_preference_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should persist the Delegation preference when it is turned on and off',
    scenarioBuilder: ($, robots) => ToggleDelegationPreferenceScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
