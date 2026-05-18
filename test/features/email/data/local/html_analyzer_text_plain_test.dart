import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/email_content_type.dart';
import 'package:mockito/annotations.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/text_plain_email_corpus.dart';
import 'html_analyzer_text_plain_test.mocks.dart';

// DioClient: required by HtmlTransform constructor; not called for text-plain path.
// FileUploader, Uuid: required by HtmlAnalyzer constructor; not called for textPlain path.
// NiceMocks avoid stubbing boilerplate for dependencies that are never invoked.
@GenerateNiceMocks([
  MockSpec<DioClient>(),
  MockSpec<FileUploader>(),
  MockSpec<Uuid>(),
])
void main() {
  group('HtmlAnalyzer.transformEmailContent — EmailContentType.textPlain', () {
    late HtmlAnalyzer htmlAnalyzer;

    setUp(() {
      // Use a real HtmlTransform so the actual transformer pipeline runs.
      htmlAnalyzer = HtmlAnalyzer(
        HtmlTransform(MockDioClient(), const HtmlEscape()),
        MockFileUploader(),
        MockUuid(),
      );
    });

    Future<EmailContent> transformPlain(String content) =>
        htmlAnalyzer.transformEmailContent(
          EmailContent(EmailContentType.textPlain, content),
          {},
          // The outer TransformConfiguration is ignored for EmailContentType.textPlain
          // — HtmlAnalyzer hard-codes its own text-transformer list in that branch.
          // An empty DOM-only config is passed to make the irrelevance explicit.
          TransformConfiguration.fromDomTransformers([]),
        );

    group('Return type and structure', () {
      test('SHOULD always return EmailContent with type textPlain', () async {
        expect((await transformPlain('Hello world')).type, equals(EmailContentType.textPlain));
      });

      test('SHOULD return empty content when input is empty', () async {
        final result = await transformPlain('');
        expect(result.type, equals(EmailContentType.textPlain));
        expect(result.content, isEmpty);
      });
    });

    group('Simple plain text emails', () {
      test('SHOULD pass through simple plain text content', () async {
        expect((await transformPlain(TextPlainEmailCorpus.simple)).content, contains('Hello Alice'));
      });

      test('SHOULD preserve all lines of a multi-line email body', () async {
        const input = 'Hi Bob,\n\nThanks for reaching out.\n\nBest,\nAlice';
        expect(
          (await transformPlain(input)).content,
          allOf(contains('Hi Bob'), contains('Thanks'), contains('Alice')),
        );
      });

      test('SHOULD preserve Unicode and emoji in email content', () async {
        expect(
          (await transformPlain(TextPlainEmailCorpus.unicode)).content,
          allOf(contains('🎉'), contains('résumé'), contains('日本語')),
        );
      });
    });

    group('HTML-special characters in plain text', () {
      test('SHOULD HTML-escape < and > so they render as text, not markup', () async {
        expect(
          (await transformPlain(TextPlainEmailCorpus.ltGtAmpersand)).content,
          allOf(contains('&lt;'), contains('&gt;')),
        );
      });

      test('SHOULD HTML-escape & so it displays as text', () async {
        expect((await transformPlain(TextPlainEmailCorpus.ampersand)).content, contains('&amp;'));
      });
    });

    group('XSS and injection blocking', () {
      test('SHOULD block <script> tag embedded in plain text email', () async {
        expect(
          (await transformPlain(TextPlainEmailCorpus.scriptTag)).content,
          isNot(contains(RegExp(r'<script\b', caseSensitive: false))),
        );
      });

      test('SHOULD prevent <img> pixel tracker from executing — tag becomes escaped text', () async {
        // When <img> appears in a plain-text email, Layer 1 HTML-escapes its
        // delimiters (< → &lt;, > → &gt;). No actual <img> element is produced
        // so onerror cannot fire.
        expect(
          (await transformPlain(TextPlainEmailCorpus.imgTracker)).content,
          isNot(contains(RegExp(r'<img\b', caseSensitive: false))),
        );
      });
    });

    group('URL autolinking', () {
      test('SHOULD convert a plain https URL to a clickable <a> link', () async {
        expect(
          (await transformPlain(TextPlainEmailCorpus.withHttpsUrl)).content,
          contains('href="https://example.com/docs"'),
        );
      });

      test('SHOULD convert a plain email address to a mailto: link', () async {
        expect((await transformPlain(TextPlainEmailCorpus.withEmailAddress)).content, contains('mailto:'));
      });

      test('SHOULD convert multiple URLs in the same email body', () async {
        expect(
          (await transformPlain(TextPlainEmailCorpus.withMultipleUrls)).content,
          allOf(
            contains('href="https://docs.example.com"'),
            contains('href="https://api.example.com/v1"'),
          ),
        );
      });
    });

    group('Backslash-hex patterns', () {
      test('SHOULD NOT produce blank output for a PHP backslash namespace email', () async {
        // \AB, \DA etc. in plain text matched unicodeEscapeReg in
        // dart-neats/sanitize_html, stripping the text node → blank output.
        expect(
          (await transformPlain(TextPlainEmailCorpus.phpNamespace)).content,
          contains(r'\App\DB\Exception\AuthFailed'),
        );
      });

      test('SHOULD preserve multi-line PHP stack trace with backslash namespaces', () async {
        expect(
          (await transformPlain(TextPlainEmailCorpus.phpStackTrace)).content,
          allOf(contains('NotFound'), contains('Dispatcher')),
        );
      });

      test('SHOULD preserve backslash namespaces AND autolink the URL in the same email', () async {
        const input =
            'On Monday, Alice wrote:\n'
            r"throw new \App\DB\Exception\AuthFailed('access denied');" '\n'
            'See https://jira.example.com/TF-4524 for context.';
        expect(
          (await transformPlain(input)).content,
          allOf(
            contains(r'\App\DB\Exception'),
            contains('href="https://jira.example.com/TF-4524"'),
          ),
        );
      });
    });

    group('Preformatted and table emails', () {
      test('SHOULD wrap a plain text markdown table in a preformatted <div>', () async {
        expect(
          (await transformPlain(TextPlainEmailCorpus.markdownTable)).content,
          allOf(contains(HtmlTemplate.markDownAndASCIIArtStyleCSS), contains('Alice')),
        );
      });

      test('SHOULD NOT wrap as preformatted when a greeting line has no ASCII-art chars', () async {
        // "Dear Bob," contains none of +, -, |, /, \, = so allLinesHaveAscii
        // becomes false and PersistPreformattedTextTransformer skips wrapping.
        const input =
            'Dear Bob,\n'
            r'throw new \App\DB\Exception\AuthFailed("access");' '\n'
            'Please see https://support.example.com for help.';
        expect(
          (await transformPlain(input)).content,
          isNot(contains(HtmlTemplate.markDownAndASCIIArtStyleCSS)),
        );
      });
    });

    group('Line ending handling', () {
      test('SHOULD preserve all content lines from a Windows CRLF email', () async {
        expect(
          (await transformPlain(TextPlainEmailCorpus.windowsCrlf)).content,
          allOf(contains('Line one'), contains('Line two'), contains('Line three')),
        );
      });
    });

    group('Quoted reply threads', () {
      test('SHOULD preserve quoted lines AND autolink the URL inside the quote', () async {
        expect(
          (await transformPlain(TextPlainEmailCorpus.quotedReply)).content,
          allOf(contains('Hi Alice'), contains('href="https://example.com/pr/42"')),
        );
      });
    });
  });
}
