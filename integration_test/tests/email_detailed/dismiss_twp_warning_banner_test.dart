import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/email_detailed/dismiss_twp_warning_banner_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should hide the TWP warning banner when dismissing it on an opened email',
    scenarioBuilder: ($, robots) => DismissTwpWarningBannerScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
