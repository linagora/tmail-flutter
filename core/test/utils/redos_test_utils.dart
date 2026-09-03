import 'package:flutter_test/flutter_test.dart';

/// Runs [action], asserts it completes within [budgetMs] milliseconds, and
/// returns its result. Centralizes the stopwatch + elapsed-time assertion that
/// every ReDoS performance test shares, so the timing criterion lives in one
/// place instead of being duplicated per test.
T expectFastResult<T>(
  T Function() action, {
  int budgetMs = 100,
  String? reason,
}) {
  final stopwatch = Stopwatch()..start();
  late final T result;
  try {
    result = action();
  } finally {
    stopwatch.stop();
  }
  // Assert the budget only after a successful return so a throwing [action]
  // surfaces its own exception instead of the timing matcher's failure.
  expect(stopwatch.elapsedMilliseconds, lessThan(budgetMs), reason: reason);
  return result;
}
