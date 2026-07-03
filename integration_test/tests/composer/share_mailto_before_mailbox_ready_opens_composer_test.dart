import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/android/share_mailto_before_mailbox_ready_opens_composer_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should open composer with mailto data when the share arrives '
        'before the mailbox is ready',
    tags: [TestTags.android],
    scenarioBuilder: ($, robots) =>
        ShareMailtoBeforeMailboxReadyOpensComposerScenario($, robots),
  );
}
