import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Locks which HTML pipeline (named `TransformConfiguration` factory) each
/// production file uses. The pipeline locks in `core` prove what each factory
/// does; this lock proves where each one is used, so a caller that switches
/// to a pipeline without a sanitizer fails here with a diff to review.
///
/// When the change is intended, regenerate from the repo root:
///
///   UPDATE_HTML_LOCKS=true fvm flutter test test/features/base/html_pipeline_call_sites_lock_test.dart
const _lockPath = 'test/fixtures/html_locks/pipeline_call_sites.txt';

final _factoryUse = RegExp(r'TransformConfiguration\.(\w+)');

String _callSites() {
  final lines = <String>[];
  for (final root in ['lib', 'core/lib']) {
    final files = Directory(root)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !file.path.endsWith('transform_configuration.dart'));
    for (final file in files) {
      for (final match in _factoryUse.allMatches(file.readAsStringSync())) {
        lines.add('${file.path}: ${match.group(1)}');
      }
    }
  }
  return '${(lines..sort()).join('\n')}\n';
}

void main() {
  test('every production call site keeps its HTML pipeline', () {
    final actual = _callSites();
    final lock = File(_lockPath);
    if (Platform.environment['UPDATE_HTML_LOCKS'] == 'true') {
      lock.writeAsStringSync(actual);
      return;
    }
    expect(actual, lock.readAsStringSync(), reason: 'If intended, regenerate: see the header of this test');
  });
}
