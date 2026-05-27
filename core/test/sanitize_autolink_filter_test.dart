import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/sanitize_autolink_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SanitizeAutolinkFilter', () {
    group('escapeHtml: true — plain-text mode', () {
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

    group('escapeHtml: false — HTML-aware mode', () {
      late SanitizeAutolinkFilter filter;

      setUp(() {
        filter = SanitizeAutolinkFilter(const HtmlEscape(), escapeHtml: false);
      });

      test(
        'SHOULD return empty string for empty input',
        () {
          expect(filter.process(''), equals(''));
        },
      );

      test(
        'SHOULD linkify a bare URL in plain text (no HTML tags)',
        () {
          final result = filter.process('Join at https://meet.example.com/room');
          expect(result, contains('href="https://meet.example.com/room"'));
          expect(result, contains('Join at'));
        },
      );

      test(
        'SHOULD linkify a bare email address in plain text',
        () {
          final result = filter.process('Contact admin@example.com for help');
          expect(result, contains('mailto:admin@example.com'));
          expect(result, contains('Contact'));
        },
      );

      test(
        'SHOULD preserve an existing <a href> without re-linkifying the URL inside the attribute',
        () {
          final result = filter.process('<a href="https://example.com/meeting">Join Zoom</a>');
          // The original href must survive intact — not double-wrapped.
          expect(result, contains('href="https://example.com/meeting"'));
          expect(result, contains('Join Zoom'));
          // No broken tag produced by double-linkification.
          expect(result, isNot(contains('<ahref')));
          // Must not produce a nested <a> inside the href attribute value.
          expect(result, isNot(contains('href="<a')));
        },
      );

      test(
        'SHOULD NOT corrupt an <a> whose visible text is also a URL',
        () {
          final result = filter.process(
            '<a href="https://example.com/a">https://example.com/a</a>',
          );
          // The original href must survive.
          expect(result, contains('href="https://example.com/a"'));
          expect(result, isNot(contains('href="<a')));
        },
      );

      test(
        'SHOULD preserve URL in <img src> without mangling the attribute',
        () {
          final result = filter.process('<img src="https://cdn.example.com/a.png"> caption');
          // The src attribute must not be double-wrapped.
          expect(result, contains('src="https://cdn.example.com/a.png"'));
          expect(result, contains('caption'));
          expect(result, isNot(contains('src="<a')));
        },
      );

      test(
        'SHOULD linkify a bare URL that appears in the text content of an HTML element',
        () {
          final result = filter.process('<p>Join at https://meet.example.com/room/9</p>');
          expect(result, contains('href="https://meet.example.com/room/9"'));
          expect(result, contains('<p>'));
        },
      );

      test(
        'SHOULD handle an HTML attribute whose value contains a > character',
        () {
          // The tag must be treated as a single token even though it contains >.
          final result = filter.process('<div title="a &gt; b">https://example.com</div>');
          expect(result, contains('title="a &gt; b"'));
          expect(result, contains('href="https://example.com"'));
        },
      );

      test(
        'SHOULD pass through HTML tags unchanged while linkifying text between them',
        () {
          final result = filter.process('<p>See <b>details</b> at https://example.com</p>');
          expect(result, contains('<p>'));
          expect(result, contains('<b>'));
          expect(result, contains('href="https://example.com"'));
        },
      );

      test(
        'SHOULD preserve URL in a single-quoted href attribute without re-linkifying it',
        () {
          // Single-quoted attributes are valid HTML and appear in real calendar invites.
          final result = filter.process("<a href='https://example.com/room'>Join</a>");
          expect(result, contains("href='https://example.com/room'"));
          expect(result, isNot(contains("href='<a")));
          expect(result, contains('Join'));
        },
      );

      test(
        'SHOULD treat a void tag (<br/>) as a tag boundary and linkify text around it',
        () {
          final result = filter.process('Before<br/>https://example.com after');
          expect(result, contains('<br/>'));
          expect(result, contains('href="https://example.com"'));
          expect(result, contains('Before'));
          expect(result, contains('after'));
        },
      );

      test(
        'SHOULD NOT crash on a malformed unclosed tag and return non-empty output',
        () {
          // The regex does not match an unclosed tag, so it falls back to
          // plain-text linkification. The behaviour is a documented fallback —
          // the primary guard is that the process must not throw.
          final result = filter.process('<a href="https://example.com"');
          expect(result, isNotNull);
          expect(result, isNot(isEmpty));
        },
      );
    });
  });
}
