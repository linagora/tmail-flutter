import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/switch_back_to_mine_via_avatar_menu_standalone_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should switch back to mine from the avatar menu while Viewing a delegated mailbox',
    scenarioBuilder: ($, robots) =>
        SwitchBackToMineViaAvatarMenuStandaloneScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}