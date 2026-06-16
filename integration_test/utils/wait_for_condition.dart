import 'dart:async';

import 'test_timeouts.dart';

Future<void> waitForCondition(
  FutureOr<bool> Function() condition, {
  Duration timeout = TestTimeouts.medium,
  Duration interval = const Duration(milliseconds: 200),
}) async {
  await Future.doWhile(() async {
    if (await condition()) {
      return false;
    }
    await Future.delayed(interval);
    return true;
  }).timeout(timeout);
}