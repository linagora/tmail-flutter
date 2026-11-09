import 'package:flutter_test/flutter_test.dart' show addTearDown;

import '../../base/base_test_scenario.dart';
import '../../memory/memory_probe.dart';

enum MemoryCycle { warmup, measured }

/// Runs one user flow twice and samples memory around the second run.
///
/// The warm-up loads lazy dependencies and fills bounded caches, so the
/// before/after delta only shows what the measured flow leaves behind.
abstract class MemoryLeakScenario extends BaseTestScenario {
  const MemoryLeakScenario(super.$, super.robots);

  String get caseId;

  /// Moves to the screen every cycle starts and ends on.
  /// Not `prepare`: that one seeds the test credentials before the app mounts.
  Future<void> openStartScreen() async {}

  /// One full user flow; it must end on the screen [openStartScreen] left.
  Future<void> runCycle(MemoryCycle cycle);

  @override
  Future<void> runTestLogic() async {
    // Profile builds drop text sent to client -1, so the mock input must own the connection.
    $.tester.testTextInput.register();
    addTearDown($.tester.testTextInput.unregister);
    await robots.commonRobot().waitForMailboxReady();
    await openStartScreen();
    await runCycle(MemoryCycle.warmup);
    await sampleMemory($, caseId: caseId, label: 'before');
    await runCycle(MemoryCycle.measured);
    await sampleMemory($, caseId: caseId, label: 'after');
  }
}
