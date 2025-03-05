import '../../base/test_base.dart';
import '../../scenarios/save_as_template_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should save email as template successfully',
    scenarioBuilder: ($) => SaveAsTemplateScenario($),
  );
} 