import '../../base/test_base.dart';
import '../../scenarios/composer/reply_inline_no_focus_at_first_line_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should insert inline at first line when user never focused composer on reply',
    scenarioBuilder: ($, robots) => ReplyInlineNoFocusAtFirstLineScenario($, robots),
  );
}
