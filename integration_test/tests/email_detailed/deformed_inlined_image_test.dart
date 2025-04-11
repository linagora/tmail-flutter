import '../../base/test_base.dart';
import '../../scenarios/email_detailed/deformed_inlined_image_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see normalized inline image when open email with content contain inline image',
    scenarioBuilder: ($) => DeformedInlinedImageScenario($),
  );
}