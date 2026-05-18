import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/email_content_type.dart';
import 'package:mockito/annotations.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/html_email_corpus.dart';
import 'html_analyzer_text_html_test.mocks.dart';

// DioClient: required by HtmlTransform constructor; not called for CID-less HTML.
// FileUploader, Uuid: required by HtmlAnalyzer constructor; not used for textHtml path.
@GenerateNiceMocks([
  MockSpec<DioClient>(),
  MockSpec<FileUploader>(),
  MockSpec<Uuid>(),
])
void main() {
  group('HtmlAnalyzer.transformEmailContent — EmailContentType.textHtml', () {
    late HtmlAnalyzer htmlAnalyzer;

    // forPreviewEmailOnWeb() is the production config for web email preview.
    final previewConfig = TransformConfiguration.forPreviewEmailOnWeb();

    setUp(() {
      htmlAnalyzer = HtmlAnalyzer(
        HtmlTransform(MockDioClient(), const HtmlEscape()),
        MockFileUploader(),
        MockUuid(),
      );
    });

    Future<EmailContent> transformHtml(String content) =>
        htmlAnalyzer.transformEmailContent(
          EmailContent(EmailContentType.textHtml, content),
          {},
          previewConfig,
        );

    group('Return type and structure', () {
      test('SHOULD always return EmailContent with type textHtml', () async {
        expect(
          (await transformHtml(HtmlEmailCorpus.htmlSimple)).type,
          equals(EmailContentType.textHtml),
        );
      });

      test('SHOULD return an empty HTML document for empty input', () async {
        // The HTML parser wraps empty content in an HTML skeleton, not isEmpty.
        final result = await transformHtml('');
        expect(result.type, equals(EmailContentType.textHtml));
        expect(result.content, isNot(contains('<script')));
        expect(result.content, isNot(contains('onerror')));
      });
    });

    group('Simple HTML preservation', () {
      test('SHOULD preserve text content from a simple HTML paragraph', () async {
        expect(
          (await transformHtml(HtmlEmailCorpus.htmlSimple)).content,
          contains('Hello World'),
        );
      });

      test('SHOULD preserve bold and hyperlink in simple HTML email', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithBoldAndLink)).content;
        expect(output, allOf(contains('Hello'), contains('World')));
        expect(output, contains('href="https://example.com"'));
      });

      test('SHOULD preserve Unicode, emoji, and accented characters', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithUnicode)).content;
        expect(output, allOf(contains('🎉'), contains('résumé'), contains('日本語')));
      });
    });

    group('Backslash namespace / path patterns in HTML text nodes', () {
      test('SHOULD preserve backslash namespace inside <code> tag', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithBackslashInCode)).content;
        expect(output, contains(r'\App\DB\Exception\AuthFailed'));
        expect(output, contains('access denied'));
      });

      test('SHOULD preserve backslash namespace across multiple HTML text nodes', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithBackslashMultipleNodes)).content;
        expect(output, allOf(contains('NotFound'), contains('Dispatcher')));
      });

      test('SHOULD preserve backslash namespace AND keep clickable <a> link in same email', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithBackslashAndLink)).content;
        expect(output, contains(r'\App\DB\Exception\AuthFailed'));
        expect(output, contains('href="https://docs.example.com/errors"'));
      });

      test('SHOULD preserve Windows file path backslashes inside <code>', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithWindowsPath)).content;
        expect(output, contains(r'C:\Users\Admin'));
        expect(output, contains('error.log'));
      });

      // Bare \XX-only text nodes are still stripped by the sanitizer.
      // Real HTML emails wrap such content in <code>/<pre> — verified above.
    });

    group('XSS blocking', () {
      test('SHOULD remove <script> tag while preserving surrounding text', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithScriptTag)).content;
        expect(output, isNot(contains('<script')));
        expect(output, allOf(contains('Before'), contains('After')));
      });

      test('SHOULD remove onerror event attribute from <img> tag', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithImgOnerror)).content;
        expect(output, isNot(contains('onerror')));
        expect(output, isNot(contains('evil.com')));
      });

      test('SHOULD sanitize javascript: href from <a> tag', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithJavascriptLink)).content;
        expect(output, isNot(contains('javascript:')));
        expect(output, contains('Click me'));
      });

      test('SHOULD remove <iframe> while preserving surrounding content', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithIframe)).content;
        expect(output, isNot(contains('<iframe')));
        expect(output, allOf(contains('Content'), contains('End')));
      });

      test('SHOULD remove phishing form elements', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithFormPhishing)).content;
        expect(output, isNot(contains('<input')));
        expect(output, isNot(contains('attacker.com')));
      });

      test('SHOULD sanitize XSS-rich email while preserving valid content', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlXssRich)).content;
        expect(output, isNot(contains('<script')));
        expect(output, isNot(contains('onerror')));
        expect(output, isNot(contains('onmouseover')));
        expect(output, contains('Valid content'));
      });

      test('SHOULD sanitize data: URI href from <a> tag', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithDataUriHref)).content;
        expect(output, isNot(contains('data:text/html')));
      });
    });

    group('Hyperlink sanitization', () {
      test('SHOULD preserve safe https and mailto hyperlinks', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithMultipleLinks)).content;
        expect(output, allOf(
          contains('href="https://example.com"'),
          contains('href="https://docs.example.com"'),
          contains('href="mailto:support@example.com"'),
        ));
      });

      test('SHOULD sanitize javascript: href in HTML email link', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithJavascriptHref)).content;
        expect(output, isNot(contains('javascript:')));
      });
    });

    group('Complex and nested HTML emails', () {
      test('SHOULD preserve text content from complex nested HTML email', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlComplexNested)).content;
        expect(output, allOf(
          contains('Monthly Performance Report'),
          contains('Engineering'),
          contains('finance portal'),
        ));
      });

      test('SHOULD preserve hyperlinks in complex HTML email', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlComplexNested)).content;
        expect(output, contains('href="https://finance.example.com/budget"'));
      });

      test('SHOULD preserve text from deeply nested HTML tags', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlDeeplyNested)).content;
        expect(output, contains('deeply nested content'));
      });

      test('SHOULD preserve structure of Markdown-rendered HTML email', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlMarkdownRendered)).content;
        expect(output, allOf(
          contains('Monthly Report'),
          contains('Revenue'),
          contains('href="https://analytics.example.com"'),
        ));
      });
    });

    group('HTML entity encoding', () {
      test('SHOULD keep &lt;script&gt; as escaped text, not execute it', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlWithEncodedEntities)).content;
        expect(output, isNot(contains('<script>')));
      });

      test('SHOULD preserve double-encoded HTML entities as safe text', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlDoubleEncoded)).content;
        expect(output, isNot(contains('<script>')));
      });
    });

    group('Multi-language and RTL content', () {
      test('SHOULD preserve RTL Arabic content in HTML email', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlRtlArabic)).content;
        expect(output, contains('مرحبا'));
      });

      test('SHOULD preserve CJK content across multiple HTML paragraphs', () async {
        final output = (await transformHtml(HtmlEmailCorpus.htmlCjk)).content;
        expect(output, allOf(contains('日本語'), contains('中文'), contains('한국어')));
      });
    });
  });
}
