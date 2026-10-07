import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Checked-in golden files that lock HTML sanitizing and transform behavior.
///
/// Any change to a locked value fails with a line diff. When the change is
/// intended, regenerate from `core/`:
///
///   UPDATE_HTML_LOCKS=true fvm flutter test test/utils/html_locks
///
/// and let the CODEOWNERS reviewer read the golden diff in the PR.
const htmlLockUpdateCommand =
    'UPDATE_HTML_LOCKS=true fvm flutter test test/utils/html_locks';

bool get _updateLocks => Platform.environment['UPDATE_HTML_LOCKS'] == 'true';

Directory htmlLockDirectory() {
  final cwd = Directory.current.path;
  for (final path in [
    '$cwd/test/fixtures/html_locks',
    '$cwd/core/test/fixtures/html_locks',
  ]) {
    final dir = Directory(path);
    if (dir.parent.existsSync()) return dir;
  }
  throw StateError('Cannot find core/test/fixtures from $cwd');
}

File htmlLockFile(String relativePath) =>
    File('${htmlLockDirectory().path}/$relativePath');

void expectMatchesHtmlLock(String relativePath, String actual) {
  final file = htmlLockFile(relativePath);
  final normalized = actual.endsWith('\n') ? actual : '$actual\n';

  if (_updateLocks) {
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(normalized);
    return;
  }

  if (!file.existsSync()) {
    fail('Missing lock file $relativePath. Run: $htmlLockUpdateCommand');
  }

  final expected = file.readAsStringSync();
  if (expected == normalized) return;

  fail(
    'HTML lock "$relativePath" changed:\n'
    '${_lineDiff(expected, normalized)}\n'
    'If this change is intended, run: $htmlLockUpdateCommand',
  );
}

/// Lists lock files in [relativeDirectory] that no test produced, so a
/// removed pipeline cannot leave a stale golden behind.
List<String> orphanHtmlLockFiles(
  String relativeDirectory,
  Set<String> expectedFileNames,
) {
  final dir = Directory('${htmlLockDirectory().path}/$relativeDirectory');
  if (!dir.existsSync()) return const [];
  return dir
      .listSync()
      .whereType<File>()
      .map((file) => file.uri.pathSegments.last)
      .where((name) => !expectedFileNames.contains(name))
      .toList()
    ..sort();
}

String _lineDiff(String expected, String actual) {
  final expectedLines = expected.split('\n');
  final actualLines = actual.split('\n');
  final buffer = StringBuffer();
  final length = expectedLines.length > actualLines.length
      ? expectedLines.length
      : actualLines.length;
  var shown = 0;
  for (var i = 0; i < length && shown < 40; i++) {
    final before = i < expectedLines.length ? expectedLines[i] : null;
    final after = i < actualLines.length ? actualLines[i] : null;
    if (before == after) continue;
    shown++;
    buffer.writeln('  line ${i + 1}:');
    if (before != null) buffer.writeln('    - $before');
    if (after != null) buffer.writeln('    + $after');
  }
  return buffer.toString();
}
