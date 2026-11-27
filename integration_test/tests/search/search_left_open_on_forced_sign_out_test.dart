import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/search_left_open_on_forced_sign_out_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should open the Inbox when signing in again after a 401 ended the session during a search',
    scenarioBuilder: ($, robots) =>
        SearchLeftOpenOnForcedSignOutScenario($, robots),
    tags: [TestTags.android, TestTags.ios],
  );
}
