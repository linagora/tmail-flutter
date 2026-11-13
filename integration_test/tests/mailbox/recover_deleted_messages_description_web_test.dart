import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/mailbox/recover_deleted_messages_description_web_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should show recover deleted messages description without duplicated day unit on web',
    tags: [TestTags.web],
    scenarioBuilder: ($, robots) => RecoverDeletedMessagesDescriptionWebScenario($, robots),
  );
}
