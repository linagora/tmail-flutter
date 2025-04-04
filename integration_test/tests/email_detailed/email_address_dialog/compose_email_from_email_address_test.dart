import '../../../base/test_base.dart';
import '../../../scenarios/email_detailed/compose_email_from_email_address_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should open new composer with To field has email address when open detailed email and tap `Compose email` button in email address info dialog',
    scenarioBuilder: ($) => ComposeEmailFromEmailAddressScenario($),
  );
}