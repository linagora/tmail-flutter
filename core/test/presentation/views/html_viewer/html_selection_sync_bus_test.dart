import 'dart:async';

import 'package:core/presentation/views/html_viewer/html_selection_sync_bus.dart';
import 'package:flutter_test/flutter_test.dart';

/// Subscribes to both bus streams, tracking how many events each received.
class _BothSidesListener {
  _BothSidesListener(HtmlSelectionSyncBus bus)
      : _flutterSub = bus.flutterSelectionStarted.listen(null),
        _iframeSub = bus.iframeSelectionStarted.listen(null) {
    _flutterSub.onData((_) => flutterCount++);
    _iframeSub.onData((_) => iframeCount++);
  }

  final StreamSubscription<void> _flutterSub;
  final StreamSubscription<void> _iframeSub;
  int flutterCount = 0;
  int iframeCount = 0;

  Future<void> cancel() async {
    await _flutterSub.cancel();
    await _iframeSub.cancel();
  }
}

void main() {
  // Locks the mutual-exclusion contract subject/body selection syncing relies on.
  group('HtmlSelectionSyncBus', () {
    tearDown(() => HtmlSelectionSyncBus.instance.release());

    test('instance is a singleton', () {
      expect(HtmlSelectionSyncBus.instance, same(HtmlSelectionSyncBus.instance));
    });

    test('notifyFlutterSelectionStarted only fires flutterSelectionStarted', () async {
      final bus = HtmlSelectionSyncBus.instance;
      final listener = _BothSidesListener(bus);

      bus.notifyFlutterSelectionStarted();
      await Future<void>.delayed(Duration.zero);

      expect(listener.flutterCount, 1);
      expect(listener.iframeCount, 0);
      await listener.cancel();
    });

    test('notifyIframeSelectionStarted only fires iframeSelectionStarted', () async {
      final bus = HtmlSelectionSyncBus.instance;
      final listener = _BothSidesListener(bus);

      bus.notifyIframeSelectionStarted();
      await Future<void>.delayed(Duration.zero);

      expect(listener.iframeCount, 1);
      expect(listener.flutterCount, 0);
      await listener.cancel();
    });

    test('broadcasts to every listener', () async {
      final bus = HtmlSelectionSyncBus.instance;
      var firstCount = 0;
      var secondCount = 0;
      final subs = [
        bus.iframeSelectionStarted.listen((_) => firstCount++),
        bus.iframeSelectionStarted.listen((_) => secondCount++),
      ];

      bus.notifyIframeSelectionStarted();
      await Future<void>.delayed(Duration.zero);

      expect(firstCount, 1);
      expect(secondCount, 1);
      for (final sub in subs) {
        await sub.cancel();
      }
    });

    test('notify* before any listener subscribes is a safe no-op', () {
      expect(HtmlSelectionSyncBus.instance.notifyFlutterSelectionStarted, returnsNormally);
      expect(HtmlSelectionSyncBus.instance.notifyIframeSelectionStarted, returnsNormally);
    });

    test('release closes the streams and notify* after release is a safe no-op', () async {
      final bus = HtmlSelectionSyncBus.instance;
      var doneCount = 0;
      final sub = bus.flutterSelectionStarted.listen(
        (_) {},
        onDone: () => doneCount++,
      );

      bus.release();
      await Future<void>.delayed(Duration.zero);

      expect(doneCount, 1);
      expect(bus.notifyFlutterSelectionStarted, returnsNormally);
      expect(bus.notifyIframeSelectionStarted, returnsNormally);
      await sub.cancel();
    });

    test('a fresh stream works again after release', () async {
      final bus = HtmlSelectionSyncBus.instance;
      bus.release();

      final events = <void>[];
      final sub = bus.iframeSelectionStarted.listen(events.add);

      bus.notifyIframeSelectionStarted();
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      await sub.cancel();
    });

    test('release is a no-op while another consumer still holds the bus', () async {
      final bus = HtmlSelectionSyncBus.instance;
      bus.acquire();
      bus.acquire();
      var doneCount = 0;
      final sub = bus.flutterSelectionStarted.listen(
        (_) {},
        onDone: () => doneCount++,
      );

      bus.release();
      await Future<void>.delayed(Duration.zero);
      expect(doneCount, 0, reason: 'stream must stay open for the remaining consumer');

      bus.release();
      await Future<void>.delayed(Duration.zero);
      expect(doneCount, 1);
      await sub.cancel();
    });
  });
}
