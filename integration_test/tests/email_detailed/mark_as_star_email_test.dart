import '../../base/test_base.dart';
import '../../scenarios/email_detailed/mark_as_star_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see star and unStar icon when open detailed email and mark as star and unStar email successfully',
    scenarioBuilder: ($) => MarkAsStarEmailScenario($),
  );
}