import '../../base/test_base.dart';
import '../../scenarios/app_grid_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should display and navigate app grid correctly when clicked',
    scenarioBuilder: ($) => AppGridScenario($),
  );
}