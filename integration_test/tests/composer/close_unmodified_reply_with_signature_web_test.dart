import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/close_unmodified_reply_with_signature_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should close an unmodified reply with a signature without asking to save on web',
    scenarioBuilder: ($, robots) => CloseUnmodifiedReplyWithSignatureScenario($, robots),
    tags: [TestTags.web],
  );
}
