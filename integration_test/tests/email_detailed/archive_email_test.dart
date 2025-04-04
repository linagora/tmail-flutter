import '../../base/test_base.dart';
import '../../scenarios/email_detailed/archive_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see email in Archive folder when open detailed email and archive email successfully',
    scenarioBuilder: ($) => ArchiveEmailScenario($),
  );
}