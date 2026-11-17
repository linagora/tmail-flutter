import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/utils/app_log_recorder.dart';

const _autoFocus = 'ComposerController::_autoFocusFieldWhenLauncher: trigger=';

// debugPrintSynchronously writes through print, so capture it in a zone.
List<String> _dump() {
  final lines = <String>[];
  runZoned(
    AppLogRecorder.instance.dump,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) => lines.add(line),
    ),
  );
  return lines;
}

void _recordsOnlyComposerFocusLines() {
  log('${_autoFocus}webEditorLoaded to=1');
  log('ComposerController::_subjectEmailInputFocusListener: focused');
  log('ThreadController::something else');

  final lines = _dump();

  expect(lines, hasLength(2));
  expect(lines[0], allOf(contains('[APP LOG] 0 at='), contains('focus='), contains('webEditorLoaded')));
  expect(lines[1], contains('_subjectEmailInputFocusListener: focused'));
}

void _ignoresRecordsAfterStop() {
  AppLogRecorder.instance.stop();
  log('${_autoFocus}webEditorLoaded to=1');

  expect(_dump(), isEmpty);
}

void _keepsOnlyTheLast40Entries() {
  for (var i = 0; i < 50; i++) {
    log('$_autoFocus#$i');
  }

  final lines = _dump();

  expect(lines, hasLength(40));
  expect(lines.first, contains('#10'));
  expect(lines.last, contains('#49'));
}

void _startClearsEarlierEntries() {
  log('${_autoFocus}old');
  AppLogRecorder.instance.start();

  expect(_dump(), isEmpty);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(AppLogRecorder.instance.start);
  tearDown(() {
    AppLogRecorder.instance.stop();
    AppLoggerRegistry.instance.resetForTesting();
  });

  test('records only the composer focus lines', _recordsOnlyComposerFocusLines);
  test('ignores records after stop', _ignoresRecordsAfterStop);
  test('keeps only the last 40 entries', _keepsOnlyTheLast40Entries);
  test('start clears earlier entries', _startClearsEarlierEntries);
}
