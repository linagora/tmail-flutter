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

  group('sidecar fields', () {
    late Directory dir;

    setUp(() => dir = Directory.systemTemp.createTempSync('html_corpus_'));
    tearDown(() => dir.deleteSync(recursive: true));

    void writeFixture(String name, String body, String sidecar) {
      Directory('${dir.path}/real').createSync();
      File('${dir.path}/real/$name.html').writeAsStringSync(body);
      File('${dir.path}/real/$name.json').writeAsStringSync(sidecar);
    }

    test('emits purpose, contentType and expect', () {
      writeFixture(
        'news',
        'Plain body',
        '{"purpose": "stacks on phones", "contentType": "text/plain", '
            '"expect": ["fullDisplay", "lazyImages"], "imageSizes": {"attr": 1}}',
      );
      final source = buildHtmlEmailCorpusDart(dir);
      expect(source, contains('purpose: "stacks on phones",'));
      expect(source, contains('contentType: "text/plain",'));
      expect(
        source,
        contains('expect: [HtmlEmailExpect.fullDisplay, HtmlEmailExpect.lazyImages],'),
      );
    });

    test('defaults to text/html with no expectations', () {
      writeFixture('bare', '<p>x</p>', '{}');
      final source = buildHtmlEmailCorpusDart(dir);
      expect(source, contains('contentType: "text/html",'));
      expect(source, contains('expect: [],'));
    });

    test('rejects an unknown expect value', () {
      writeFixture('typo', '<p>x</p>', '{"expect": ["fullDisplai"]}');
      expect(() => buildHtmlEmailCorpusDart(dir), throwsFormatException);
    });

    test(r'escapes $ so prices do not break the generated Dart', () {
      writeFixture('price', r'<p>Only $19.99 ${x}</p>', r'{"purpose": "costs $1"}');
      final source = buildHtmlEmailCorpusDart(dir);
      expect(source, contains(r'html: "<p>Only \$19.99 \${x}</p>",'));
      expect(source, contains(r'purpose: "costs \$1",'));
    });

    test('rejects a sidecar field of the wrong type', () {
      writeFixture('typed', '<p>x</p>', '{"expect": [1], "rtl": "yes"}');
      expect(() => buildHtmlEmailCorpusDart(dir), throwsFormatException);
      writeFixture('typed', '<p>x</p>', '{"contentType": 3}');
      expect(() => buildHtmlEmailCorpusDart(dir), throwsFormatException);
    });

    test('rejects an unknown contentType', () {
      writeFixture('odd', '<p>x</p>', '{"contentType": "text/markdown"}');
      expect(() => buildHtmlEmailCorpusDart(dir), throwsFormatException);
    });
  });
}
