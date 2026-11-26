import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/email_detailed/display_text_plain_email_with_quoted_url_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should keep a quoted URL inside the link of a plain-text email',
    scenarioBuilder: ($, robots) =>
        DisplayTextPlainEmailWithQuotedUrlScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
