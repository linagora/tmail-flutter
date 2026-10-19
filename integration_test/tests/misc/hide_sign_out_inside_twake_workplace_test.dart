import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/misc/hide_sign_out_inside_twake_workplace_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should hide sign out from the profile menu when the app runs inside Twake Workplace',
    scenarioBuilder: ($, robots) => HideSignOutInsideTwakeWorkplaceScenario($, robots),
    tags: [TestTags.web],
  );
}
