import 'package:core/presentation/views/html_viewer/html_selection_sync_bus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Locks the mutual-exclusion contract subject/body selection syncing relies on.
  group('HtmlSelectionSyncBus', () {
    test('instance is a singleton', () {
      expect(HtmlSelectionSyncBus.instance, same(HtmlSelectionSyncBus.instance));
    });

    test('notifyFlutterSelectionStarted only fires flutterSelectionStarted', () async {
      final bus = HtmlSelectionSyncBus.instance;
      final flutterEvents = <void>[];
      final iframeEvents = <void>[];
      final subs = [
        bus.flutterSelectionStarted.listen(flutterEvents.add),
        bus.iframeSelectionStarted.listen(iframeEvents.add),
      ];

      bus.notifyFlutterSelectionStarted();
      await Future<void>.delayed(Duration.zero);

      expect(flutterEvents, hasLength(1));
      expect(iframeEvents, isEmpty);
      for (final sub in subs) {
        await sub.cancel();
      }
    });

    test('notifyIframeSelectionStarted only fires iframeSelectionStarted', () async {
      final bus = HtmlSelectionSyncBus.instance;
      final flutterEvents = <void>[];
      final iframeEvents = <void>[];
      final subs = [
        bus.flutterSelectionStarted.listen(flutterEvents.add),
        bus.iframeSelectionStarted.listen(iframeEvents.add),
      ];

      bus.notifyIframeSelectionStarted();
      await Future<void>.delayed(Duration.zero);

      expect(iframeEvents, hasLength(1));
      expect(flutterEvents, isEmpty);
      for (final sub in subs) {
        await sub.cancel();
      }
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
  });
}
