import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/utils/primary_focus_logger.dart';

void main() {
  tearDown(PrimaryFocusLogger.instance.stop);

  testWidgets('start then stop leaves dump safe to call', _startThenStopLeavesDumpSafe);
  testWidgets('dump does not throw when primary focus is null', _dumpSafeWhenPrimaryFocusNull);
  testWidgets('start records primary focus changes into dump history', _startRecordsHistory);
  testWidgets('history keeps only the last 20 primary focus changes', _historyKeepsLastTwenty);
  testWidgets('stop stops recording further primary focus changes', _stopStopsRecording);
}

Future<void> _startThenStopLeavesDumpSafe(WidgetTester tester) async {
  await tester.pumpWidget(
    const Directionality(
      textDirection: TextDirection.ltr,
      child: FocusScope(
        child: Focus(child: SizedBox(width: 1, height: 1)),
      ),
    ),
  );

  final logger = PrimaryFocusLogger.instance;
  logger.start();
  logger.stop();
  expect(() => logger.dump(), returnsNormally);
}

Future<void> _dumpSafeWhenPrimaryFocusNull(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  final logger = PrimaryFocusLogger.instance;
  logger.start();
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  expect(() => logger.dump(), returnsNormally);
  logger.stop();
}

Future<void> _startRecordsHistory(WidgetTester tester) async {
  final node = FocusNode(debugLabel: 'recorded');
  addTearDown(node.dispose);

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: FocusScope(
        child: Focus(focusNode: node, child: const SizedBox(width: 1, height: 1)),
      ),
    ),
  );

  final logger = PrimaryFocusLogger.instance;
  logger.start();
  node.requestFocus();
  await tester.pump();

  final lines = _capturePrints(logger.dump);
  expect(
    lines.where((line) => line.contains('[PRIMARY FOCUS] history')),
    isNotEmpty,
    reason: 'start must register a FocusManager listener that buffers history',
  );
  expect(
    lines.any((line) => line.contains('label=recorded')),
    isTrue,
    reason: 'history must name the focused node',
  );
}

Future<void> _historyKeepsLastTwenty(WidgetTester tester) async {
  final nodes = List.generate(25, (i) => FocusNode(debugLabel: 'n$i'));
  addTearDown(() {
    for (final node in nodes) {
      node.dispose();
    }
  });

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: FocusScope(
        child: Column(
          children: [
            for (final node in nodes)
              Focus(focusNode: node, child: const SizedBox(width: 1, height: 1)),
          ],
        ),
      ),
    ),
  );

  final logger = PrimaryFocusLogger.instance;
  logger.start();
  for (final node in nodes) {
    node.requestFocus();
    await tester.pump();
  }

  final history = _capturePrints(logger.dump)
      .where((line) => line.contains('[PRIMARY FOCUS] history'))
      .toList();
  expect(history, hasLength(20));
  expect(history.first, contains('label=n5'));
  expect(history.last, contains('label=n24'));
  expect(history.any((line) => line.contains('label=n0')), isFalse);
}

Future<void> _stopStopsRecording(WidgetTester tester) async {
  final first = FocusNode(debugLabel: 'before-stop');
  final second = FocusNode(debugLabel: 'after-stop');
  addTearDown(first.dispose);
  addTearDown(second.dispose);

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: FocusScope(
        child: Column(
          children: [
            Focus(focusNode: first, child: const SizedBox(width: 1, height: 1)),
            Focus(focusNode: second, child: const SizedBox(width: 1, height: 1)),
          ],
        ),
      ),
    ),
  );

  final logger = PrimaryFocusLogger.instance;
  logger.start();
  first.requestFocus();
  await tester.pump();
  logger.stop();

  List<String> historyLines() => _capturePrints(logger.dump)
      .where((line) => line.contains('[PRIMARY FOCUS] history'))
      .toList();

  final afterStop = historyLines();
  second.requestFocus();
  await tester.pump();
  final afterFocusWhileStopped = historyLines();

  expect(
    afterFocusWhileStopped,
    afterStop,
    reason: 'stop must remove the FocusManager listener',
  );
  expect(afterStop, isNotEmpty);
  expect(
    afterFocusWhileStopped.any((line) => line.contains('label=after-stop')),
    isFalse,
  );
}

List<String> _capturePrints(void Function() action) {
  final lines = <String>[];
  runZoned(
    action,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        lines.add(line);
      },
    ),
  );
  return lines;
}
