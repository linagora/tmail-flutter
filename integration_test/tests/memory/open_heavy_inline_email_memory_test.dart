import 'package:flutter_test/flutter_test.dart' show Timeout;
import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/memory/open_heavy_inline_email_memory_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should not leak memory after opening an email with a heavy inline image',
    scenarioBuilder: ($, robots) => OpenHeavyInlineEmailMemoryScenario($, robots),
    tags: [TestTags.web, TestTags.android, TestTags.memory],
    timeout: const Timeout(Duration(minutes: 12)),
  );
}
