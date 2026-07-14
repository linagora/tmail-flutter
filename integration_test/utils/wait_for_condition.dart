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
  final deadline = DateTime.now().add(timeout);

  while (true) {
    if (await condition()) return;

    // Checked after the condition so the deadline stops the loop itself; a
    // timeout wrapped around the loop would leave it polling forever in the
    // background and bleed into later tests.
    if (!DateTime.now().isBefore(deadline)) {
      throw TimeoutException('waitForCondition timed out', timeout);
    }
    await Future.delayed(interval);
  }
}
