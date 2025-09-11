import '../../base/test_base.dart';
import '../../scenarios/email_detailed/delete_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see email in Trash folder when open detailed email and delete email successfully',
    scenarioBuilder: ($) => DeleteEmailScenario($),
  );
}