import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/thread_detail/close_thread_detail_with_escape_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should close the thread detail when pressing Escape',
    scenarioBuilder: ($, robots) => CloseThreadDetailWithEscapeScenario($, robots),
    tags: [TestTags.web],
  );
}
