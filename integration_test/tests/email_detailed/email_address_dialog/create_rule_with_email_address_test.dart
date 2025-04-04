import '../../../base/test_base.dart';
import '../../../scenarios/email_detailed/create_rule_with_email_address_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should open new rule filter creator view with condition field has email address when open detailed email and tap `Create a rule with this email address` button in email address info dialog',
    scenarioBuilder: ($) => CreateRuleWithEmailAddressScenario($),
  );
}