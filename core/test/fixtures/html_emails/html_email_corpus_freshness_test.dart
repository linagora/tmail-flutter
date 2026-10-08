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

  test(r'escapes $ so prices do not break the generated Dart', () {
    final dir = Directory.systemTemp.createTempSync('corpus');
    addTearDown(() => dir.deleteSync(recursive: true));
    Directory('${dir.path}/edge').createSync();
    File('${dir.path}/edge/price.html').writeAsStringSync(r'<p>Total $19.99 for $customer</p>');
    final source = buildHtmlEmailCorpusDart(dir);
    expect(source, contains(r'Total \$19.99 for \$customer'));
  });
}
