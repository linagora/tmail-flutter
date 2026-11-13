@TestOn('vm')

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CSP `script-src` allows the sha256 of `printing` 5.12.0 `layoutPdf`'s fixed
/// inline helper. A lockfile bump without a matching hash breaks web PDF print.
void main() {
  const pinnedPrintingVersion = '5.12.0';
  const layoutPdfScriptSha256 =
      'sha256-+M0fGRkOqgYlCQCff9oNQn6k6a7Si4Et8iofLMceadE=';

  test('pubspec.lock keeps printing at $pinnedPrintingVersion for the CSP sha',
      () {
    final workspaceRoot = _workspaceRoot();
    final lock = File('${workspaceRoot.path}/pubspec.lock').readAsStringSync();
    final version = RegExp(
      r'^  printing:\n(?:    .*\n)*?    version: "([^"]+)"',
      multiLine: true,
    ).firstMatch(lock)?.group(1);

    expect(
      version,
      pinnedPrintingVersion,
      reason:
          'CSP script-src pins $layoutPdfScriptSha256 for printing '
          '$pinnedPrintingVersion layoutPdf. Recompute that hash before '
          'changing the lockfile version.',
    );

    final cspTemplate = File(
      '${workspaceRoot.path}/server/csp-headers.conf.template',
    ).readAsStringSync();
    expect(
      cspTemplate,
      contains(layoutPdfScriptSha256),
      reason:
          'server/csp-headers.conf.template must keep the printing '
          '$pinnedPrintingVersion layoutPdf sha256.',
    );
  });
}

Directory _workspaceRoot() {
  var directory = Directory.current.absolute;
  while (true) {
    if (_isWorkspaceRoot(directory)) {
      return directory;
    }
    final parent = directory.parent;
    if (parent.path == directory.path) {
      fail('workspace pubspec.lock not found; run from the repo root or core/');
    }
    directory = parent;
  }
}

bool _isWorkspaceRoot(Directory directory) {
  final lock = File('${directory.path}/pubspec.lock');
  if (!lock.existsSync()) {
    return false;
  }
  final pubspec = File('${directory.path}/pubspec.yaml');
  if (!pubspec.existsSync()) {
    return false;
  }
  return pubspec.readAsStringSync().contains('\nworkspace:');
}
