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

  while (true) {
    if (await condition()) return;

    if (elapsed.elapsed >= timeout) {
      throw TimeoutException('waitForCondition timed out', timeout);
    }
    await Future.delayed(interval);
  }
}
