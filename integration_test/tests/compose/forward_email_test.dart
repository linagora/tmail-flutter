import '../../base/test_base.dart';
import '../../scenarios/forward_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see HTML content contain enough: Subject, From, To, Cc, Bcc, Reply to',
    scenarioBuilder: ($) => ForwardEmailScenario($),
  );
}