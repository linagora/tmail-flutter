import '../../base/test_base.dart';
import '../../scenarios/composer/reply_inline_focused_with_signature_inserts_under_signature_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should insert inline under signature and above reply body when user focused composer with signature',
    scenarioBuilder: ($, robots) =>
        ReplyInlineFocusedWithSignatureInsertsUnderSignatureScenario($, robots),
  );
}
