import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// UI outside `delegation/` asks `ShownAccountCapabilities` instead of reading `isDelegated`
/// (ADR-0114). Domain/notifier/session helpers keep the property.
final _allowedIsDelegatedPaths = {
  'lib/features/delegation/domain/model/active_account.dart',
  'lib/features/delegation/domain/extensions/session_delegation_extension.dart',
  'lib/features/delegation/presentation/model/shown_account_capabilities.dart',
  'lib/features/delegation/presentation/notifier/active_account_notifier.dart',
};

final _lineComment = RegExp(r'^[ \t]*//.*$', multiLine: true);
final _isDelegatedRead = RegExp(r'\bisDelegated\b|\bisDelegatedAccountShown\b|\bisDelegatedAccount\b');

void main() {
  test('isDelegated for the UI lives only in delegation/', () {
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart') && !file.path.endsWith('.g.dart'));
    for (final file in files) {
      if (_allowedIsDelegatedPaths.contains(file.path)) continue;
      final source = file.readAsStringSync().replaceAll(_lineComment, '');
      if (_isDelegatedRead.hasMatch(source)) {
        offenders.add(file.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Ask ShownAccountCapabilities for a feature, or add the file to the allowlist '
          'with why it needs isDelegated: $offenders',
    );
  });
}
