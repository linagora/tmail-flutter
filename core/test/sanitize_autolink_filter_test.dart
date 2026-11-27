import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/sanitize_autolink_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;

void main() {
  group('SanitizeAutolinkFilter', () {
    late SanitizeAutolinkFilter filter;

    setUp(() {
      filter = SanitizeAutolinkFilter(const HtmlEscape());
    });

    test(
      'SHOULD wrap https URL in an anchor tag',
      () {
        expect(
          filter.process('See https://linagora.com at Hanoi'),
          equals('See <a href="https://linagora.com" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">linagora.com</a> at Hanoi'),
        );
      },
    );

    test(
      'SHOULD wrap http URL in an anchor tag',
      () {
        expect(
          filter.process('See http://linagora.com at Hanoi'),
          equals('See <a href="http://linagora.com" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">linagora.com</a> at Hanoi'),
        );
      },
    );

    test(
      'SHOULD wrap www URL in an anchor tag',
      () {
        expect(
          filter.process('See www.linagora.com at Hanoi'),
          equals('See <a href="https://www.linagora.com" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">linagora.com</a> at Hanoi'),
        );
      },
    );

    test(
      'SHOULD wrap email address in a mailto anchor tag',
      () {
        expect(
          filter.process('See tdvu@linagora.com at Hanoi'),
          equals('See <a href="mailto:tdvu@linagora.com" style="white-space: nowrap; word-break: keep-all;">tdvu@linagora.com</a> at Hanoi'),
        );
      },
    );

    test(
      'SHOULD HTML-escape angle brackets so raw tags are not injected',
      () {
        final result = filter.process('<b>bold</b>');
        expect(result, contains('&lt;b&gt;'));
        expect(result, isNot(contains('<b>')));
      },
    );

    test(
      'SHOULD escape quotes in URL href and link text',
      () {
        expect(
          filter.process('aa.aa#"style="x"'),
          equals('<a href="https://aa.aa#&quot;style=&quot;x&quot;" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">aa.aa#&quot;style=&quot;x&quot;</a>'),
        );
      },
    );

    test(
      'SHOULD keep a single quote and angle bracket inside the link',
      () {
        const input = 'aa.aa#style="x"=\'<';
        final body = html_parser.parse(filter.process(input)).body!;
        expect(body.text, equals(input));
        final links = body.querySelectorAll('a');
        expect(links, hasLength(1));
        expect(
          links.first.attributes.keys.map((k) => k.toString()).toSet(),
          equals({'href', 'target', 'rel', 'style'}),
        );
        expect(
          links.first.attributes['style'],
          equals('white-space: nowrap; word-break: keep-all;'),
        );
      },
    );

    test(
      'SHOULD NOT create elements from a quoted email local part',
      () {
        const input = '"a<b"@x.y';
        final body = html_parser.parse(filter.process(input)).body!;
        expect(body.text, equals(input));
        expect(body.children.every((e) => e.localName == 'a'), isTrue);
      },
    );

    test(
      'SHOULD keep the closing quote of a double-quoted URL outside the link',
      () {
        expect(
          filter.process('Open "https://example.com/docs" now'),
          equals('Open &quot;<a href="https://example.com/docs" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">example.com&#47;docs</a>&quot; now'),
        );
      },
    );

    test(
      'SHOULD return empty string for empty input',
      () {
        expect(filter.process(''), equals(''));
      },
    );
  });
}
