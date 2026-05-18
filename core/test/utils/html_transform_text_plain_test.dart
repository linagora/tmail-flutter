import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/text/persist_preformatted_text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_autolink_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_plain_text_html_output_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import '../../../test/fixtures/text_plain_email_corpus.dart';
import 'html_transform_text_plain_test.mocks.dart';

// DioClient is required by HtmlTransform's constructor but is never called
// during the text-plain code path (it is only used in transformToHtml for DOM
// transforms that download remote resources). A NiceMock lets the constructor
// succeed without any stubbing.
@GenerateNiceMocks([MockSpec<DioClient>()])
void main() {
  group('HtmlTransform.transformToTextPlain', () {
    late HtmlTransform htmlTransform;

    // Mirror the configuration hard-coded in HtmlAnalyzer.transformEmailContent
    // for EmailContentType.textPlain.
    final textPlainConfig = TransformConfiguration.fromTextTransformers([
      const SanitizeAutolinkHtmlTransformers(),
      const SanitizePlainTextHtmlOutputTransformer(),
      const PersistPreformattedTextTransformer(),
    ]);

    setUp(() {
      htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
    });

    String transform(String content) => htmlTransform.transformToTextPlain(
          content: content,
          transformConfiguration: textPlainConfig,
        );

    group('Empty and whitespace content', () {
      test('SHOULD return empty string when content is empty', () {
        expect(transform(''), isEmpty);
      });

      test('SHOULD NOT crash and preserve whitespace-only content', () {
        expect(transform('   ').trim(), isEmpty);
      });
    });

    group('Simple plain text', () {
      test('SHOULD preserve single-line plain text unchanged', () {
        expect(transform('Hello world'), equals('Hello world'));
      });

      test('SHOULD preserve all lines of a multi-line plain text', () {
        const input = 'First line\nSecond line\nThird line';
        expect(
          transform(input),
          allOf(contains('First line'), contains('Second line'), contains('Third line')),
        );
      });

      test('SHOULD preserve Unicode and international characters unchanged', () {
        // Arabic, emoji, accented Latin, CJK — none are HTML-special and
        // must survive the transformer pipeline without modification.
        const input = 'مرحبا 🎉 résumé 日本語 한국어';
        expect(transform(input), equals(input));
      });

      test('SHOULD preserve a multi-paragraph email with blank lines', () {
        expect(
          transform(TextPlainEmailCorpus.multiLine),
          allOf(contains('Alice'), contains('Bob')),
        );
      });
    });

    group('HTML-special characters', () {
      test('SHOULD HTML-escape < and > so they display as text, not markup', () {
        expect(
          transform('if (a < b && b > 0) return;'),
          allOf(contains('&lt;'), contains('&gt;')),
        );
      });

      test('SHOULD HTML-escape & so it displays as text', () {
        expect(transform('Tom & Jerry'), contains('&amp;'));
      });

      test('SHOULD preserve double-quoted text as readable content', () {
        // Layer 1 escapes " → &quot;. Layer 2's HTML serializer outputs it back
        // as " in text context (valid there). Net result: " is visible as-is.
        expect(transform('She said "Hello World" to them'), contains('Hello World'));
      });

      test('SHOULD preserve HTML entity literals present in the plain text', () {
        expect(transform('Price: 10 &amp; discount &lt;5%&gt;'), contains('discount'));
      });
    });

    group('XSS and injection blocking', () {
      test('SHOULD block <script> tag injected in plain text', () {
        expect(
          transform('Hello <script>alert("xss")</script> world'),
          isNot(contains(RegExp(r'<script\b', caseSensitive: false))),
        );
      });

      test('SHOULD prevent <img> tracker from executing — tag becomes escaped text', () {
        // When <img> appears in plain text, Layer 1 HTML-escapes its delimiters
        // (< → &lt;, > → &gt;). No actual <img> element is produced so the
        // onerror attribute cannot fire.
        const input = 'Click <img src="https://tracker.com/1x1.gif" onerror="alert(1)"> here';
        expect(transform(input), isNot(contains(RegExp(r'<img\b', caseSensitive: false))));
      });

      test('SHOULD prevent inline event handler from executing — tag becomes escaped text', () {
        // <div onclick=...> in plain text is HTML-escaped by Layer 1, so no
        // actual <div> element is produced and onclick cannot fire.
        expect(
          transform('<div onclick="steal()">Click me</div>'),
          isNot(contains(RegExp(r'<div\b', caseSensitive: false))),
        );
      });
    });

    group('URL autolinking', () {
      test('SHOULD autolink https URL to a clickable <a> tag', () {
        expect(transform('See https://example.com for details'), contains('href="https://example.com"'));
      });

      test('SHOULD autolink http URL', () {
        expect(transform('Visit http://example.com'), contains('href="http://example.com"'));
      });

      test('SHOULD autolink plain email address to mailto: link', () {
        expect(transform('Contact support@example.com for help'), contains('mailto:'));
      });

      test('SHOULD autolink URL that contains a query string with special chars', () {
        const input = 'See https://example.com/search?q=hello+world&lang=en for results';
        expect(transform(input), contains('https://example.com/search'));
      });

      test('SHOULD autolink URL inside a complex Markdown-formatted plain text', () {
        expect(
          transform(TextPlainEmailCorpus.markdownBody),
          contains('href="https://analytics.example.com/may-2026"'),
        );
      });

      test('SHOULD preserve surrounding plain text alongside an autolinked URL', () {
        const input = 'Visit https://example.com — the best site!';
        expect(
          transform(input),
          allOf(contains('href="https://example.com"'), contains('best site')),
        );
      });
    });

    group('Backslash-hex patterns', () {
      test('SHOULD preserve PHP-style backslash namespace on a single line', () {
        // \AB, \DA, \DB — two hex digits after backslash — triggered
        // unicodeEscapeReg in dart-neats/sanitize_html, stripping the text node.
        expect(
          transform(r'throw new \App\DB\Exception\AuthFailed("access denied");'),
          contains(r'\App\DB\Exception\AuthFailed'),
        );
      });

      test('SHOULD preserve Go package import path with backslash separators', () {
        expect(transform(TextPlainEmailCorpus.goPackagePath), contains('handler'));
      });

      test('SHOULD preserve backslash namespaces AND autolink the URL in the same email', () {
        const input =
            'On Monday, Alice wrote:\n'
            r"throw new \App\DB\Exception\AuthFailed('access denied');" '\n'
            'See https://example.com/issues for details.';
        expect(
          transform(input),
          allOf(contains(r'\App\DB\Exception'), contains('href="https://example.com/issues"')),
        );
      });

      test('SHOULD NOT produce blank output when all lines contain hex backslash pairs', () {
        // Even if all lines match the ASCII-art heuristic, the content must not be blank.
        expect(
          transform(r'\AB\CD path one' '\n' r'\EF\01 path two'),
          isNot(isEmpty),
        );
      });

      test('SHOULD preserve Windows file path with backslash separators', () {
        // \Ad in C:\Users\Admin contains two hex chars (a, d) — potential false-positive.
        expect(
          transform(TextPlainEmailCorpus.windowsFilePath),
          allOf(contains(r'C:\Users\Admin'), isNot(isEmpty)),
        );
      });

      test('SHOULD preserve PHP namespace AND autolink the URL in the same email', () {
        expect(
          transform(TextPlainEmailCorpus.phpNamespaceWithUrl),
          allOf(
            contains(r'\App\DB\Exception'),
            contains('href="https://jira.example.com/issues/1234"'),
          ),
        );
      });
    });

    group('Preformatted / table content', () {
      test('SHOULD wrap a markdown table in a preformatted <div>', () {
        expect(
          transform(TextPlainEmailCorpus.markdownTable),
          allOf(contains(HtmlTemplate.markDownAndASCIIArtStyleCSS), contains('Alice')),
        );
      });

      test('SHOULD wrap a markdown table AND preserve clickable URL in a table cell', () {
        // The separator row |---|---| is unaffected by the URL autolinker, so
        // PersistPreformattedTextTransformer still detects the table correctly.
        expect(
          transform(TextPlainEmailCorpus.markdownTableWithUrl),
          allOf(
            contains(HtmlTemplate.markDownAndASCIIArtStyleCSS),
            contains('href="https://alice.com/page"'),
          ),
        );
      });

      test('SHOULD wrap ASCII art box in a preformatted <div>', () {
        expect(
          transform(TextPlainEmailCorpus.asciiArtBox),
          allOf(contains(HtmlTemplate.markDownAndASCIIArtStyleCSS), contains('Alice')),
        );
      });

      test('SHOULD NOT wrap as preformatted when a greeting line has no ASCII-art chars', () {
        // "Dear Bob," contains none of +, -, |, /, \, = so allLinesHaveAscii
        // becomes false and PersistPreformattedTextTransformer skips wrapping.
        const input =
            'Dear Bob,\n'
            r'throw new \App\DB\Exception\AuthFailed("access");' '\n'
            'Please contact https://support.example.com';
        expect(transform(input), isNot(contains(HtmlTemplate.markDownAndASCIIArtStyleCSS)));
      });
    });

    group('Line ending handling', () {
      test('SHOULD preserve all content lines from a Windows CRLF email', () {
        const input = 'Line one\r\nLine two\r\nLine three';
        expect(
          transform(input),
          allOf(contains('Line one'), contains('Line two'), contains('Line three')),
        );
      });

      test('SHOULD preserve all content lines from an email with mixed LF and CRLF', () {
        const input = 'First\r\nSecond\nThird\r\nFourth';
        expect(
          transform(input),
          allOf(contains('First'), contains('Second'), contains('Third'), contains('Fourth')),
        );
      });
    });

    group('Quoted reply thread content', () {
      test('SHOULD preserve quoted lines AND autolink the URL inside the quote', () {
        expect(
          transform(TextPlainEmailCorpus.quotedReply),
          allOf(contains('Hi Alice'), contains('href="https://example.com/pr/42"')),
        );
      });
    });

    group('Code snippets in plain text', () {
      test('SHOULD HTML-escape comparison operators in code so they display as text', () {
        const input = 'if (x > 0 && y < 100) {\n  return "valid";\n}';
        expect(transform(input), allOf(contains('&lt;'), contains('&gt;')));
      });

      test('SHOULD preserve Python-style code with arrow and braces', () {
        expect(transform(TextPlainEmailCorpus.pythonCode), contains('greet'));
      });

      test('SHOULD HTML-escape XML tags embedded in plain text so they display as text', () {
        expect(
          transform(TextPlainEmailCorpus.xmlBody),
          allOf(isNot(contains('<response>')), contains('&lt;response&gt;')),
        );
      });
    });
  });
}
