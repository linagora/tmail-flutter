import '../../../base/test_base.dart';
import '../../../models/test_tags.dart';
import '../../../scenarios/setting/preferences/toggle_preferences_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should toggle local and network preferences successfully',
    scenarioBuilder: ($, robots) => TogglePreferencesScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}