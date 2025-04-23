import '../../base/test_base.dart';
import '../../scenarios/search/search_snippets_with_html_escape_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see email with subject escaped when search email successfully',
    scenarioBuilder: ($) => SearchSnippetsWithHtmlEscapeScenario($),
  );
}