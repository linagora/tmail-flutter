import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/utils/frame_state_recorder.dart';
import '../../integration_test/utils/primary_focus_logger.dart';

List<String> _lines = [];

// debugPrintSynchronously writes through print, so capture it in a zone.
void _harnessTest(String name, Future<void> Function(WidgetTester) body) {
  testWidgets(name, (tester) async {
    _lines = [];
    await tester.pumpWidget(const SizedBox.shrink());
    try {
      await runZoned(
        () => body(tester),
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => _lines.add(line),
        ),
      );
    } finally {
      FrameStateRecorder.stopAll();
    }
  });
}

// The recorder never schedules frames, so the test supplies the one a live app has.
Future<void> _frame(WidgetTester tester) async {
  tester.binding.scheduleFrame();
  await tester.pump();
}

Future<void> _recordsStartThenOnlyChanges(WidgetTester tester) async {
  var value = 'a';
  FrameStateRecorder('T', () => value).start();
  await _frame(tester);
  await _frame(tester);
  await _frame(tester);
  value = 'b';
  await _frame(tester);
  await _frame(tester);

  FrameStateRecorder.dumpActive();

  expect(_lines.where((l) => l.contains('event=start a')), hasLength(1));
  expect(_lines.where((l) => l.endsWith(' a') && !l.contains('event=')), isEmpty);
  expect(_lines.where((l) => l.endsWith(' b')), hasLength(1));
}

Future<void> _throwingSnapshotIsLogged(WidgetTester tester) async {
  FrameStateRecorder('T', () => throw StateError('boom')).start();
  await _frame(tester);

  FrameStateRecorder.dumpActive();

  expect(_lines.any((l) => l.contains('snapshot failed')), isTrue);
}

Future<void> _repeatedFailureIsLoggedOnce(WidgetTester tester) async {
  FrameStateRecorder('T', () => throw StateError('boom')).start();
  await _frame(tester);
  await _frame(tester);
  await _frame(tester);

  FrameStateRecorder.dumpActive();

  expect(_lines.where((l) => l.contains('snapshot failed')), hasLength(1));
}

Future<void> _restartingTagReplacesOldRecorder(WidgetTester tester) async {
  FrameStateRecorder('T', () => 'old').start();
  FrameStateRecorder('T', () => 'new').start();
  await _frame(tester);

  FrameStateRecorder.dumpActive();

  expect(_lines.any((l) => l.contains('old')), isFalse);
  expect(_lines.any((l) => l.contains('new')), isTrue);
}

Future<void> _stopAllClearsTheDump(WidgetTester tester) async {
  var value = 'a';
  FrameStateRecorder('T', () => value).start();
  FrameStateRecorder.stopAll();
  value = 'b';
  await _frame(tester);
  await _frame(tester);

  FrameStateRecorder.dumpActive();

  expect(_lines, isEmpty);
}

Future<void> _doesNotKeepFrameScheduled(WidgetTester tester) async {
  FrameStateRecorder('T', () => 'a').start();
  await _frame(tester);
  await _frame(tester);

  expect(tester.binding.hasScheduledFrame, isFalse);
}

Future<void> _keepsLast40Entries(WidgetTester tester) async {
  var count = 0;
  FrameStateRecorder('T', () => '${count++}').start();
  for (var i = 0; i < 60; i++) {
    await _frame(tester);
  }

  FrameStateRecorder.dumpActive();

  expect(_lines, hasLength(40));
}

Future<void> _describeFocusKeyNamesKeyedAncestor(WidgetTester tester) async {
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
  await _frame(tester);

  expect(describeFocusKey(node), contains("key=[<'field'>]"));
  expect(describeFocusKey(null), 'null');
}

void main() {
  _harnessTest('records start then only changed snapshots', _recordsStartThenOnlyChanges);
  _harnessTest('a throwing snapshot is logged and does not throw', _throwingSnapshotIsLogged);
  _harnessTest('a repeatedly failing snapshot is logged once', _repeatedFailureIsLoggedOnce);
  _harnessTest('restarting the same tag replaces the old recorder', _restartingTagReplacesOldRecorder);
  _harnessTest('stopAll stops recording and clears the dump', _stopAllClearsTheDump);
  _harnessTest('does not keep a frame scheduled', _doesNotKeepFrameScheduled);
  _harnessTest('keeps only the last 40 entries', _keepsLast40Entries);
  _harnessTest('describeFocusKey names the nearest keyed ancestor', _describeFocusKeyNamesKeyedAncestor);
}
