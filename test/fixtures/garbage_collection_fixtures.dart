import 'dart:async';
import 'dart:developer';

class GarbageCollectionFixtures {
  const GarbageCollectionFixtures._();

  /// Allocates until the VM has run full garbage collections, so only strongly
  /// reachable objects survive. Run it through `tester.runAsync` in widget
  /// tests.
  ///
  /// Throws a [TimeoutException] after [timeout] instead of looping forever
  /// where collections are not reported, e.g. on web.
  static Future<void> forceGarbageCollection({
    int fullGcCycles = 2,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final stopwatch = Stopwatch()..start();
    final barrier = reachabilityBarrier;
    final storage = <List<int>>[];
    while (reachabilityBarrier < barrier + fullGcCycles) {
      if (stopwatch.elapsed > timeout) {
        throw TimeoutException(
          'No garbage collection observed; run this test on the Dart VM',
          timeout,
        );
      }
      await Future<void>.delayed(Duration.zero);
      storage.add(List.generate(30000, (n) => n));
      if (storage.length > 100) storage.removeAt(0);
    }
  }
}
