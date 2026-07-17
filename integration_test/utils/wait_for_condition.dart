import 'dart:async';

import 'test_timeouts.dart';

/// Polls [condition] until it returns true, or throws [TimeoutException] after
/// [timeout].
///
/// Only suitable for conditions that stay true once reached. To observe a
/// momentary signal, subscribe before triggering it — see `waitForViewState`.
Future<void> waitForCondition(
  FutureOr<bool> Function() condition, {
  Duration timeout = TestTimeouts.medium,
  Duration interval = const Duration(milliseconds: 200),
}) async {
  final elapsed = Stopwatch()..start();
  Never timedOut() => throw TimeoutException('waitForCondition timed out', timeout);

  while (true) {
    final remaining = timeout - elapsed.elapsed;
    if (remaining <= Duration.zero) timedOut();

    if (await Future.sync(condition).timeout(remaining, onTimeout: timedOut)) {
      return;
    }
    await Future.delayed(interval);
  }
}
