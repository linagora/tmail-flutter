import '../../../base/test_base.dart';
import '../../../scenarios/setting/language/change_language_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see title in Setting change language when successfully selecting another language',
    scenarioBuilder: ($) => ChangeLanguageScenario($),
  );
}