import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/email_rules/create_edit_rule_with_reject_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see warning dialog when create or edit rule with reject action',
    tags: [TestTags.android, TestTags.ios, TestTags.web],
    scenarioBuilder: ($, robots) => CreateEditRuleWithRejectScenario($, robots),
  );
}