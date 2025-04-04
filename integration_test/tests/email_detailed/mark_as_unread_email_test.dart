import '../../base/test_base.dart';
import '../../scenarios/email_detailed/mark_as_unread_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see email item has unread icon when open detailed email and select mark as unread email successfully',
    scenarioBuilder: ($) => MarkAsUnreadEmailScenario($),
  );
}