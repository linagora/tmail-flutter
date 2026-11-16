import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/utils/frame_state_recorder.dart';
import '../../integration_test/utils/primary_focus_logger.dart';

void main() {
  late List<String> lines;

  // debugPrintSynchronously writes through print, so capture it in a zone.
  void harnessTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      lines = [];
      await tester.pumpWidget(const SizedBox.shrink());
      try {
        await runZoned(
          () => body(tester),
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, line) => lines.add(line),
          ),
        );
      } finally {
        FrameStateRecorder.stopAll();
      }
    });
  }

  // The recorder never schedules frames, so the test supplies the one a live app has.
  Future<void> frame(WidgetTester tester) async {
    tester.binding.scheduleFrame();
    await tester.pump();
  }

  harnessTest('records start then only changed snapshots', (tester) async {
    var value = 'a';
    FrameStateRecorder('T', () => value).start();
    await frame(tester);
    await frame(tester);
    await frame(tester);
    value = 'b';
    await frame(tester);
    await frame(tester);

    FrameStateRecorder.dumpActive();

    expect(lines.where((l) => l.contains('event=start a')), hasLength(1));
    expect(lines.where((l) => l.endsWith(' a') && !l.contains('event=')), isEmpty);
    expect(lines.where((l) => l.endsWith(' b')), hasLength(1));
  });

  harnessTest('a throwing snapshot is logged and does not throw', (tester) async {
    FrameStateRecorder('T', () => throw StateError('boom')).start();
    await frame(tester);

    FrameStateRecorder.dumpActive();

    expect(lines.any((l) => l.contains('snapshot failed')), isTrue);
  });

  harnessTest('a repeatedly failing snapshot is logged once', (tester) async {
    FrameStateRecorder('T', () => throw StateError('boom')).start();
    await frame(tester);
    await frame(tester);
    await frame(tester);

    FrameStateRecorder.dumpActive();

    expect(lines.where((l) => l.contains('snapshot failed')), hasLength(1));
  });

  harnessTest('restarting the same tag replaces the old recorder', (tester) async {
    FrameStateRecorder('T', () => 'old').start();
    FrameStateRecorder('T', () => 'new').start();
    await frame(tester);

    FrameStateRecorder.dumpActive();

    expect(lines.any((l) => l.contains('old')), isFalse);
    expect(lines.any((l) => l.contains('new')), isTrue);
  });

  harnessTest('stopAll stops recording and clears the dump', (tester) async {
    var value = 'a';
    FrameStateRecorder('T', () => value).start();
    FrameStateRecorder.stopAll();
    value = 'b';
    await frame(tester);
    await frame(tester);

    FrameStateRecorder.dumpActive();

    expect(lines, isEmpty);
  });

  harnessTest('does not keep a frame scheduled', (tester) async {
    FrameStateRecorder('T', () => 'a').start();
    await frame(tester);
    await frame(tester);

    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  harnessTest('keeps only the last 40 entries', (tester) async {
    var count = 0;
    FrameStateRecorder('T', () => '${count++}').start();
    for (var i = 0; i < 60; i++) {
      await frame(tester);
    }

    FrameStateRecorder.dumpActive();

    expect(lines, hasLength(40));
  });

  harnessTest('describeFocusKey names the nearest keyed ancestor', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: KeyedSubtree(
          key: const ValueKey('field'),
          child: Focus(focusNode: node, child: const SizedBox(width: 1, height: 1)),
        ),
      ),
    );
    node.requestFocus();
    await frame(tester);

    expect(describeFocusKey(node), contains("key=[<'field'>]"));
    expect(describeFocusKey(null), 'null');
  });
}
