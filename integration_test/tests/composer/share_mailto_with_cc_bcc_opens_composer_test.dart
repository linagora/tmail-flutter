import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/android/share_mailto_with_cc_bcc_opens_composer_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should open composer with the cc and bcc of a shared mailto link',
    tags: [TestTags.android],
    scenarioBuilder: ($, robots) =>
        ShareMailtoWithCcBccOpensComposerScenario($, robots),
  );
}
