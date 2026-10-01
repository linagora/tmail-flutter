import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/email_rules/rule_move_action_excludes_outgoing_folders_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should hide Outbox, Drafts and Templates when picking the folder of a move message rule',
    tags: [TestTags.android, TestTags.ios, TestTags.web],
    scenarioBuilder: ($, robots) => RuleMoveActionExcludesOutgoingFoldersScenario($, robots),
  );
}
