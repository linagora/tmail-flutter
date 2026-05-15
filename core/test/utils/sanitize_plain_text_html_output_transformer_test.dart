import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/text/sanitize_autolink_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_plain_text_html_output_transformer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SanitizePlainTextHtmlOutputTransformer.process', () {
    const transformer = SanitizePlainTextHtmlOutputTransformer();
    const htmlEscape = HtmlEscape();

    String process(String input) => transformer.process(input, htmlEscape);

    group('Text nodes – preserved as-is', () {
      test('SHOULD preserve plain text unchanged', () {
        expect(process('Hello world'), equals('Hello world'));
      });

      test('SHOULD preserve HTML-escaped entities as text', () {
        // &lt;script&gt; from the autolinker must stay escaped, not execute.
        const input = 'Hello &lt;script&gt;alert(1)&lt;/script&gt; world';
        expect(process(input), equals(input));
      });

      test('SHOULD preserve backslash-hex patterns that triggered the original bug', () {
        // Backslash followed by two hex digits (e.g. \AB, \DE) matched the
        // library unicodeEscapeReg and caused the entire text node to be stripped.
        // This transformer must NOT strip such text nodes.
        const input = r'throw new \App\DB\Exception\AuthFailed("access denied")';
        expect(process(input), contains(r'\App\DB\Exception'));
      });
    });

    group('<a> tags – allowed with attribute allowlist', () {
      test('SHOULD preserve <a> with https href and all safe attributes', () {
        const input =
            '<a href="https://example.com" target="_blank" rel="noreferrer" '
            'style="white-space: nowrap;">example.com</a>';
        final out = process(input);
        expect(out, contains('href="https://example.com"'));
        expect(out, contains('target="_blank"'));
        expect(out, contains('rel="noreferrer"'));
        expect(out, contains('style='));
        expect(out, contains('example.com'));
      });

      test('SHOULD preserve <a> with mailto href', () {
        const input = '<a href="mailto:user@example.com">user@example.com</a>';
        expect(process(input), contains('href="mailto:user@example.com"'));
      });

      test('SHOULD preserve <a> with http href', () {
        const input = '<a href="http://example.com">link</a>';
        expect(process(input), contains('href="http://example.com"'));
      });

      test('SHOULD strip dangerous attributes FROM safe <a>', () {
        const input =
            '<a href="https://example.com" onclick="alert(1)" data-x="evil">link</a>';
        final out = process(input);
        expect(out, isNot(contains('onclick')));
        expect(out, isNot(contains('data-x')));
        expect(out, contains('href="https://example.com"'));
      });
    });

    group('<a> tags – unsafe href removed', () {
      test('SHOULD clear all attributes FROM <a> WHEN href is javascript:', () {
        const input = '<a href="javascript:alert(1)" target="_blank">Click</a>';
        final out = process(input);
        expect(out, equals('<a>Click</a>'));
        expect(out, isNot(contains('javascript:')));
      });

      test('SHOULD clear all attributes FROM <a> WHEN href is data: URI', () {
        const input = '<a href="data:text/html,<h1>x</h1>">Click</a>';
        final out = process(input);
        expect(out, equals('<a>Click</a>'));
        expect(out, isNot(contains('data:')));
      });

      test('SHOULD clear all attributes FROM <a> WHEN href is vbscript:', () {
        const input = '<a href="vbscript:msgbox(1)">Click</a>';
        final out = process(input);
        expect(out, equals('<a>Click</a>'));
      });

      test('SHOULD clear all attributes FROM <a> WHEN href has leading whitespace obfuscation', () {
        const input = '<a href="  javascript:alert(1)">Click</a>';
        final out = process(input);
        expect(out, isNot(contains('javascript:')));
        expect(out, contains('<a>Click</a>'));
      });

      test('SHOULD clear all attributes FROM <a> WHEN href is empty', () {
        const input = '<a href="">Click</a>';
        final out = process(input);
        expect(out, equals('<a>Click</a>'));
      });

      test('SHOULD clear all attributes FROM <a> WHEN href is a relative path', () {
        // Relative URLs have no scheme — they must not be preserved because
        // they could resolve to unexpected origins inside a webview.
        const input = '<a href="/evil/path">Click</a>';
        final out = process(input);
        expect(out, equals('<a>Click</a>'));
      });

      test('SHOULD preserve <a> WHEN href scheme is uppercase (HTTPS)', () {
        // Uri.tryParse normalises the scheme to lowercase before comparison,
        // so HTTPS:// must be accepted the same as https://.
        const input = '<a href="HTTPS://example.com">link</a>';
        final out = process(input);
        expect(out, contains('href="HTTPS://example.com"'));
      });
    });

    group('Non-<a> elements – unwrapped', () {
      test('SHOULD unwrap <div> AND keep its text content', () {
        expect(process('<div>Hello world</div>'), equals('Hello world'));
      });

      test('SHOULD produce empty body WHEN root-level <script> appears', () {
        // The HTML5 parser moves a root-level <script> to <head>, leaving
        // body empty. Safe: no script content reaches the email view.
        final out = process('<script>alert(1)</script>');
        expect(out, isNot(contains('<script')));
        expect(out.trim(), isEmpty);
      });

      test('SHOULD unwrap <script> nested in block element AND keep text', () {
        // When <script> is inside a block element the parser keeps it in body.
        // Defense-in-depth unwraps it: the JS source becomes harmless plain text.
        final out = process('<div><script>alert(1)</script></div>');
        expect(out, isNot(contains('<script')));
        expect(out, contains('alert(1)'));
      });

      test('SHOULD unwrap <img> AND discard it (no text children)', () {
        final out = process('<img src="https://tracker.com/1x1.gif">');
        expect(out.trim(), isEmpty);
      });

      test('SHOULD unwrap nested non-<a> elements', () {
        expect(process('<div><span>Hello</span></div>'), equals('Hello'));
      });

      test('SHOULD unwrap outer non-<a> AND preserve inner <a>', () {
        const input = '<div><a href="https://example.com">link</a></div>';
        final out = process(input);
        expect(out, contains('<a href="https://example.com"'));
        expect(out, isNot(contains('<div')));
      });
    });

    group('Comments – removed', () {
      test('SHOULD remove HTML comments', () {
        expect(process('Hello<!-- injected --> world'), equals('Hello world'));
      });

      test('SHOULD remove comments inside <a>', () {
        const input = '<a href="https://example.com"><!-- x -->link</a>';
        final out = process(input);
        expect(out, isNot(contains('<!--')));
        expect(out, contains('link'));
      });
    });

    group('Display correctness – edge cases', () {
      test('SHOULD preserve empty string input', () {
        expect(process(''), isEmpty);
      });

      test('SHOULD preserve whitespace-only input', () {
        // Whitespace has no tags to sanitize — returned as-is.
        final out = process('   ');
        expect(out.trim(), isEmpty);
      });

      test('SHOULD double-encode HTML entities that appear literally in plain text', () {
        // If source plain text contains "&amp;" literally, after htmlEscape it
        // becomes "&amp;amp;" — the browser renders this as "&amp;", which is
        // the correct display of the original plain text character sequence.
        const input = 'price &amp; discount &lt;10%&gt;';
        expect(process(input), equals('price &amp; discount &lt;10%&gt;'));
      });

      test('SHOULD preserve Unicode and multibyte characters unchanged', () {
        // Arabic, emoji, accented Latin — none of these are HTML-significant
        // and must survive the sanitizer unmodified.
        const input = 'مرحبا 🎉 résumé 日本語';
        expect(process(input), equals('مرحبا 🎉 résumé 日本語'));
      });
    });

    group('Integration with SanitizeAutolinkHtmlTransformers', () {
      test(
        'SHOULD preserve plain text with PHP namespace separators (regression for \\Sabre\\DAV bug)',
        () {
          // Before fix: StandardizeHtmlSanitizingTransformers ran on raw plain text.
          // Backslash + two hex digits (e.g. \AB in a PHP-style namespace like
          // \App\DB\Exception) matched unicodeEscapeReg → entire text stripped → blank email.
          // Now: autolinker escapes HTML, then this transformer only checks tags.
          const plainText =
              r"throw new \App\DB\Exception\AuthFailed('access denied');";
          final autolinked =
              const SanitizeAutolinkHtmlTransformers().process(plainText, htmlEscape);
          final sanitized = transformer.process(autolinked, htmlEscape);
          expect(sanitized, contains('AuthFailed'));
          expect(sanitized, contains(r'\App\DB\Exception'));
        },
      );

      test('SHOULD escape XSS attempts embedded in plain text', () {
        const plainText = 'Hello <script>alert(1)</script> world';
        final autolinked =
            const SanitizeAutolinkHtmlTransformers().process(plainText, htmlEscape);
        final sanitized = transformer.process(autolinked, htmlEscape);
        // The <script> tag must not be executable in the output.
        expect(sanitized, isNot(contains('<script>')));
        expect(sanitized, contains('Hello'));
        expect(sanitized, contains('world'));
      });

      test('SHOULD produce clickable <a> link for URLs in plain text', () {
        const plainText = 'Visit https://example.com for details';
        final autolinked =
            const SanitizeAutolinkHtmlTransformers().process(plainText, htmlEscape);
        final sanitized = transformer.process(autolinked, htmlEscape);
        expect(sanitized, contains('href="https://example.com"'));
        expect(sanitized, contains('for details'));
      });

      test('SHOULD remove javascript: URL from link produced by autolinker', () {
        // Hypothetical: if a linkifier bug produced a javascript: href,
        // the sanitizer must strip it.
        const fakeAutolinkerOutput =
            'Click <a href="javascript:alert(1)" target="_blank">here</a>';
        final sanitized = transformer.process(fakeAutolinkerOutput, htmlEscape);
        expect(sanitized, isNot(contains('javascript:')));
        expect(sanitized, contains('here'));
      });

      test('SHOULD preserve content from email with Windows CRLF line endings', () {
        // Emails from Outlook and Exchange often use \r\n.
        // The autolinker must not corrupt the text; the sanitizer must pass it through.
        const plainText = 'Line one\r\nLine two\r\nLine three';
        final autolinked =
            const SanitizeAutolinkHtmlTransformers().process(plainText, htmlEscape);
        final sanitized = transformer.process(autolinked, htmlEscape);
        expect(sanitized, contains('Line one'));
        expect(sanitized, contains('Line two'));
        expect(sanitized, contains('Line three'));
      });

      test('SHOULD autolink URL that contains special chars in query string', () {
        // The autolinker HTML-escapes & and < in URL query params.
        // The sanitizer must keep the resulting href intact.
        const plainText = 'See https://example.com/search?q=hello+world&lang=en for info';
        final autolinked =
            const SanitizeAutolinkHtmlTransformers().process(plainText, htmlEscape);
        final sanitized = transformer.process(autolinked, htmlEscape);
        expect(sanitized, contains('https://example.com/search'));
        expect(sanitized, contains('for info'));
      });

      test(
        'SHOULD preserve email with quoted lines, PHP array syntax, and backslash namespaces (full regression case)',
        () {
          // Reproduces the class of content that triggered the original bug:
          // – email-style quoted lines (> prefix)
          // – PHP arrow operator in array literals (['key' => $val])
          // – backslash-hex namespace separators (\AB, \DE patterns)
          // – a URL that should become an autolink
          const plainText =
              'On Monday, Alice wrote:\n'
              r"> query(['field' => \$value]);" '\n'
              r"throw new \App\DB\Exception\AuthFailed('access denied');" '\n'
              'See https://example.com/project/issues for details.';
          final autolinked =
              const SanitizeAutolinkHtmlTransformers().process(plainText, htmlEscape);
          final sanitized = transformer.process(autolinked, htmlEscape);
          expect(sanitized, contains('Alice'));
          expect(sanitized, contains('AuthFailed'));
          expect(sanitized, contains('href="https://example.com/project/issues"'));
        },
      );
    });
  });
}
