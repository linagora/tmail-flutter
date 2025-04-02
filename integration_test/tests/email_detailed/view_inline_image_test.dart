import '../../base/test_base.dart';
import '../../scenarios/email_detailed/view_inline_image_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see inline image when open email with inline image',
    scenarioBuilder: ($) => ViewInlineImageScenario($),
  );
}