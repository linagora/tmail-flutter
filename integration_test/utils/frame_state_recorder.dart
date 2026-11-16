import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

const _maxEntries = 40;

// Records a state snapshot after each frame, keeping only changes; printed by the failure dump.
// Never schedules a frame itself, so pumpAndSettle still settles.
class FrameStateRecorder {
  FrameStateRecorder(this.tag, this._snapshot);

  static final _active = <String, FrameStateRecorder>{};

  final String tag;
  final String Function() _snapshot;
  final _entries = <String>[];
  final _clock = Stopwatch();
  String? _last;
  bool _running = false;

  void start() {
    _active.remove(tag)?._running = false;
    _active[tag] = this;
    _running = true;
    _clock.start();
    record('start');
    _scheduleNext();
  }

  void record(String event) => _add('event=$event ${_safeSnapshot()}');

  void _scheduleNext() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_running) return;
      final previous = _last;
      final state = _safeSnapshot();
      if (state != previous) _add(state);
      _scheduleNext();
    });
  }

  String _safeSnapshot() {
    try {
      return _last = _snapshot();
    } catch (e) {
      return _last = 'snapshot failed: $e';
    }
  }

  void _add(String text) {
    _entries.add('t=${_clock.elapsedMilliseconds}ms $text');
    if (_entries.length > _maxEntries) _entries.removeAt(0);
  }

  void _dump() {
    for (var i = 0; i < _entries.length; i++) {
      debugPrintSynchronously('[$tag] $i ${_entries[i]}');
    }
  }

  static void dumpActive() {
    for (final recorder in _active.values) {
      recorder._dump();
    }
  }

  static void stopAll() {
    for (final recorder in _active.values) {
      recorder._running = false;
    }
    _active.clear();
  }
}
