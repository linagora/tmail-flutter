import 'package:flutter_test/flutter_test.dart' show Timeout;
import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/memory/identity_heavy_inline_memory_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should not leak memory after creating an identity with a heavy inline signature image',
    scenarioBuilder: ($, robots) => IdentityHeavyInlineMemoryScenario($, robots),
    tags: [TestTags.web, TestTags.android, TestTags.memory],
    timeout: const Timeout(Duration(minutes: 12)),
  );
}
