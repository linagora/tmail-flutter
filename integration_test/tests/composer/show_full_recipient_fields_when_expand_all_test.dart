import '../../base/test_base.dart';
import '../../scenarios/composer/show_full_recipient_fields_when_expand_all_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should see all recipient fields when expand all recipients in composer',
    scenarioBuilder: ($) => ShowFullRecipientFieldsWhenExpandAllScenario($),
  );
}
