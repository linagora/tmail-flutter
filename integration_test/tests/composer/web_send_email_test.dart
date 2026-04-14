import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/web_send_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: '[Web] Should see success toast when send email successfully',
    tags: [TestTags.web],
    scenarioBuilder: ($) => WebSendEmailScenario($),
  );
}