import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/add_recipient_when_chips_fill_line_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should keep a wide input to add a recipient '
        'when the Cc chips almost fill their line',
    scenarioBuilder: ($, robots) => AddRecipientWhenChipsFillLineScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
