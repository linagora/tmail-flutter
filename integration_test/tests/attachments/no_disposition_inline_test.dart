import '../../base/test_base.dart';
import '../../scenarios/no_disposition_inline_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see base64 inline image when attachment has no disposition but has cid',
    scenarioBuilder: ($) => NoDispositionInlineScenario($),
  );
}