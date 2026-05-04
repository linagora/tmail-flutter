import '../../base/test_base.dart';
import '../../scenarios/composer/reply_inline_focused_without_signature_inserts_above_reply_body_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should insert inline above reply body when user focused composer without signature',
    scenarioBuilder: ($, robots) =>
        ReplyInlineFocusedWithoutSignatureInsertsAboveReplyBodyScenario($, robots),
  );
}
