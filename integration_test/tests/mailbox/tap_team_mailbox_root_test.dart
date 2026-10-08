import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/mailbox/tap_team_mailbox_root_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should expand a team mailbox root instead of opening it when tapping it',
    scenarioBuilder: ($, robots) => TapTeamMailboxRootScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
