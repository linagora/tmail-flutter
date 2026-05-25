import 'dart:async';

Future<void> waitForCondition(
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 20),
  Duration interval = const Duration(seconds: 1),
}) async {
  await Future.doWhile(() async {
    if (await condition()) {
      return false;
    }
    await Future.delayed(interval);
    return true;
  }).timeout(timeout);
}