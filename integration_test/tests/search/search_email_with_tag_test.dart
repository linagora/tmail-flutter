import '../../base/test_base.dart';
import '../../scenarios/search/search_email_with_tag_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should display email list correctly when search with tag',
    scenarioBuilder: ($) => SearchEmailWithTagScenario($),
  );
}
