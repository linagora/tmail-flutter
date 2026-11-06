import 'package:flutter_test/flutter_test.dart' show Timeout;
import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/memory/two_composers_heavy_send_memory_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should not leak memory after sending composers with a heavy inline image and attachment',
    scenarioBuilder: ($, robots) => TwoComposersHeavySendMemoryScenario($, robots),
    tags: [TestTags.web, TestTags.android, TestTags.memory],
    timeout: const Timeout(Duration(minutes: 12)),
  );
}
