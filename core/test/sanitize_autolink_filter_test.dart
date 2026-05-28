import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/sanitize_autolink_filter.dart';
import 'package:flutter_test/flutter_test.dart';

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
      'SHOULD return empty string for empty input',
      () {
        expect(filter.process(''), equals(''));
      },
    );
  });
}
