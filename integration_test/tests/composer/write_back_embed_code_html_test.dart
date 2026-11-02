import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/write_back_embed_code_html_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should keep event handlers typed in the Embed code view out of the composer body when the editor HTML is written back',
    scenarioBuilder: ($, robots) => WriteBackEmbedCodeHtmlScenario($, robots),
    tags: [TestTags.web],
  );
}
