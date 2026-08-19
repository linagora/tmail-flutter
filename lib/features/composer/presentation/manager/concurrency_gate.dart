import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Counting semaphore: at most [maxConcurrent] actions run at once. The limit
/// belongs to the instance, so every caller sharing one gate shares one budget
/// — a second batch queues behind the first instead of doubling the load.
class ConcurrencyGate {
  ConcurrencyGate(int maxConcurrent)
      : maxConcurrent = maxConcurrent < 1 ? 1 : maxConcurrent;

  final int maxConcurrent;

  final Queue<Completer<void>> _waiting = Queue<Completer<void>>();
  int _inFlight = 0;

  @visibleForTesting
  int get inFlight => _inFlight;

  Future<T> run<T>(Future<T> Function() action) async {
    await _acquire();
    try {
      return await action();
    } finally {
      _release();
    }
  }

  Future<void> _acquire() {
    if (_inFlight < maxConcurrent) {
      _inFlight++;
      return Future<void>.value();
    }
    final waiter = Completer<void>();
    _waiting.add(waiter);
    return waiter.future;
  }

  /// Hands the slot to the next waiter rather than releasing it, so a queued
  /// action is never overtaken by a caller arriving later.
  void _release() {
    if (_waiting.isNotEmpty) {
      _waiting.removeFirst().complete();
      return;
    }
    _inFlight--;
  }
}
