import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/text/persist_preformatted_text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_autolink_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_plain_text_html_output_transformer.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Pipeline order mirrors HtmlAnalyzer.transformEmailContent for EmailContentType.textPlain:
  //   Layer 1: SanitizeAutolinkHtmlTransformers  — HTML-escapes all text; autolinks URLs.
  //   Layer 2: SanitizePlainTextHtmlOutputTransformer — keeps only <a> with safe href; unwraps others.
  //   Layer 3: PersistPreformattedTextTransformer — detects ASCII art / markdown tables; wraps in <div>.
  group('Plain-text transformer pipeline (all 3 layers)', () {
    const htmlEscape = HtmlEscape();

    String runPipeline(String input) {
      String result = const SanitizeAutolinkHtmlTransformers().process(input, htmlEscape);
      result = const SanitizePlainTextHtmlOutputTransformer().process(result, htmlEscape);
      result = const PersistPreformattedTextTransformer().process(result, htmlEscape);
      return result;
    }

    group('Plain text — no special content', () {
      test('SHOULD pass through a single plain-text line unchanged', () {
        const input = 'Hello world';
        final out = runPipeline(input);
        expect(out, contains('Hello world'));
        expect(out, isNot(contains('<div')));
        expect(out, isNot(isEmpty));
      });

      test('SHOULD return empty string for empty input', () {
        expect(runPipeline(''), isEmpty);
      });

      test('SHOULD preserve Unicode and multibyte characters unchanged', () {
        const input = 'مرحبا 🎉 résumé 日本語';
        final out = runPipeline(input);
        expect(out, contains('مرحبا'));
        expect(out, contains('🎉'));
        expect(out, contains('résumé'));
        expect(out, contains('日本語'));
      });
    });

    group('Regression — backslash-hex false-positive (TF-4524)', () {
      // Root cause: StandardizeHtmlSanitizingTransformers ran on raw plain text.
      // unicodeEscapeReg matched \XX patterns (e.g. \AB, \DA) and stripped
      // the entire text node, producing a blank email.
      test(
        'SHOULD preserve PHP-style backslash namespace patterns through all 3 layers',
        () {
          const input =
              r'throw new \App\DB\Exception\AuthFailed("access denied");';
          final out = runPipeline(input);
          expect(out, isNot(isEmpty));
          expect(out, contains(r'\App\DB\Exception'));
          expect(out, contains('AuthFailed'));
        },
      );

      test(
        'SHOULD preserve multi-line PHP email with backslash namespaces AND URL',
        () {
          // Reproduces the class of content that triggered the original bug.
          // Critical: Layer 1 must not strip text; Layer 3 must not false-wrap
          // because the first "normal" line prevents allLinesHaveAscii from staying true.
          const input =
              'On Monday, Alice wrote:\n'
              r"throw new \App\DB\Exception\AuthFailed('access denied');" '\n'
              'See https://example.com/issues for details.';
          final out = runPipeline(input);
          expect(out, contains('Alice'));
          expect(out, contains('AuthFailed'));
          expect(out, contains(r'\App\DB\Exception'));
          expect(out, contains('href="https://example.com/issues"'));
          // Must NOT be wrapped as preformatted: the "On Monday" line has no
          // ASCII-art characters, so PersistPreformattedTextTransformer cannot
          // conclude that all lines match the ASCII-art heuristic.
          expect(out, isNot(contains(HtmlTemplate.markDownAndASCIIArtStyleCSS)));
        },
      );
    });

    group('URL autolinking', () {
      test('SHOULD convert URL to clickable <a> link through all 3 layers', () {
        const input = 'Visit https://example.com for more details';
        final out = runPipeline(input);
        expect(out, contains('href="https://example.com"'));
        expect(out, contains('for more details'));
      });

      test(
        'SHOULD strip javascript: URL if linkifier ever produces one (defense-in-depth)',
        () {
          // Layer 1 should not produce javascript: links from plain text.
          // This test verifies that if such a link somehow reached Layer 2,
          // Layer 2 strips the href attribute as a safety net.
          const hypotheticalLayer1Output =
              '<a href="javascript:alert(1)" target="_blank">click here</a>';
          String result = const SanitizePlainTextHtmlOutputTransformer()
              .process(hypotheticalLayer1Output, htmlEscape);
          result = const PersistPreformattedTextTransformer()
              .process(result, htmlEscape);
          expect(result, isNot(contains('javascript:')));
          expect(result, contains('click here'));
        },
      );
    });

    group('XSS blocking', () {
      test('SHOULD escape and block <script> tags injected in plain text', () {
        const input = 'Hello <script>alert(1)</script> world';
        final out = runPipeline(input);
        expect(out, isNot(contains('<script>')));
        expect(out, contains('Hello'));
        expect(out, contains('world'));
      });

      test('SHOULD block <img> tracking pixel embedded in plain text', () {
        const input =
            'Text before <img src="https://tracker.com/pixel.gif"> text after';
        final out = runPipeline(input);
        expect(out, isNot(contains('<img')));
        expect(out, contains('Text before'));
        expect(out, contains('text after'));
      });
    });

    group('Preformatted detection — PersistPreformattedTextTransformer', () {
      test(
        'SHOULD wrap markdown table in preformatted <div> when no URLs are present',
        () {
          const input =
              '| Name  | Score |\n'
              '|-------|-------|\n'
              '| Alice | 100   |\n'
              '| Bob   | 90    |';
          final out = runPipeline(input);
          expect(out, contains('<div'));
          expect(out, contains(HtmlTemplate.markDownAndASCIIArtStyleCSS));
          expect(out, contains('Alice'));
          expect(out, contains('Bob'));
        },
      );

      test(
        'SHOULD wrap markdown table AND preserve clickable URL in a table cell',
        () {
          // The separator row "|---|---|" makes Layer 3 detect this as a markdown
          // table regardless of the <a> tag produced by Layer 1 in the data row.
          const input =
              '| Name  | Link                    |\n'
              '|-------|-------------------------|\n'
              '| Alice | https://alice.com/page  |';
          final out = runPipeline(input);
          expect(out, contains('<div'));
          expect(out, contains(HtmlTemplate.markDownAndASCIIArtStyleCSS));
          expect(out, contains('href="https://alice.com/page"'));
          expect(out, contains('Alice'));
        },
      );

      test(
        'SHOULD NOT wrap multi-line plain text as preformatted WHEN at least one line has no ASCII-art characters',
        () {
          // PersistPreformattedTextTransformer uses _asciiArtRegex = [+\-|/\\=].
          // After Layer 1, lines containing <a> tags have "/" and "=" from HTML
          // attributes. However, if any single line lacks these characters
          // (e.g. a greeting line), allLinesHaveAscii becomes false and no wrapping occurs.
          //
          // Note: "Dear Bob," contains none of +, -, |, /, \, = so it breaks
          // the allLinesHaveAscii condition immediately.
          const input =
              'Dear Bob,\n'
              r'throw new \App\DB\Exception\AuthFailed("access denied");' '\n'
              'Please see https://docs.example.com for help.';
          final out = runPipeline(input);
          expect(out, isNot(contains(HtmlTemplate.markDownAndASCIIArtStyleCSS)));
          expect(out, contains('Bob'));
          expect(out, contains(r'\App\DB\Exception'));
          expect(out, contains('href="https://docs.example.com"'));
        },
      );
    });

    group('Line ending handling', () {
      test('SHOULD preserve content from email with Windows CRLF line endings', () {
        const input = 'Line one\r\nLine two\r\nLine three';
        final out = runPipeline(input);
        expect(out, contains('Line one'));
        expect(out, contains('Line two'));
        expect(out, contains('Line three'));
      });
    });
  });
}
