@TestOn('vm')

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/generate_html_email_corpus.dart';

void main() {
  test('html_email_corpus.g.dart matches the html fixtures', () {
    final expected = buildHtmlEmailCorpusDart();
    final actual = File(
      '${htmlEmailCorpusDirectory().path}/html_email_corpus.g.dart',
    ).readAsStringSync();
    expect(
      actual,
      expected,
      reason: 'run `fvm dart run tool/generate_html_email_corpus.dart` from core/',
    );
  });
}
