import '../../base/test_base.dart';
import '../../scenarios/mailbox/change_email_flag_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see emails with expected flag after changed',
    scenarioBuilder: ($) => ChangeEmailFlagScenario($),
  );
}
