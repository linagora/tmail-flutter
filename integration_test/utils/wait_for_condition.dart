import 'dart:async';

import 'package:flutter_test/flutter_test.dart' show fail;

import 'test_timeouts.dart';

/// Polls [condition] until it returns true, or throws [TimeoutException] after
/// [timeout]. With [reason], a timeout fails the test with
/// "<reason> within <n> seconds" instead.
///
/// Only suitable for conditions that stay true once reached. To observe a
/// momentary signal, subscribe before triggering it — see `waitForViewState`.
Future<void> waitForCondition(
  FutureOr<bool> Function() condition, {
  Duration timeout = TestTimeouts.medium,
  Duration interval = const Duration(milliseconds: 200),
  String? reason,
}) async {
  final elapsed = Stopwatch()..start();
  Never timedOut() => reason == null
      ? throw TimeoutException('waitForCondition timed out', timeout)
      : fail('$reason within ${timeout.inSeconds} seconds');

  while (true) {
    final remaining = timeout - elapsed.elapsed;
    if (remaining <= Duration.zero) timedOut();

    if (await Future.sync(condition).timeout(remaining, onTimeout: timedOut)) {
      return;
    }
    await Future.delayed(interval);
  }
}
