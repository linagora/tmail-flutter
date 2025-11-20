import '../../base/test_base.dart';
import '../../scenarios/reply_email_with_content_contain_image_base64_data_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see inline image with cid when reply email with content contain image base64 data',
    scenarioBuilder: ($) => ReplyEmailWithContentContainImageBase64DataScenario($),
  );
}