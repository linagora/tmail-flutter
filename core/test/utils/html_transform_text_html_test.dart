import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/sanitize_hyper_link_tag_in_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/script_transformers.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import '../../../test/fixtures/html_email_corpus.dart';
import 'html_transform_text_html_test.mocks.dart';

// DioClient is required by HtmlTransform's constructor but is never called
// for HTML content that has no CID images. A NiceMock lets the constructor
// succeed without any stubbing.
@GenerateNiceMocks([MockSpec<DioClient>()])
void main() {
  group('HtmlTransform.transformToHtml — standardDomTransformers + standardTextTransformers', () {
    late HtmlTransform htmlTransform;

    final config = TransformConfiguration.standardConfiguration;

    setUp(() {
      htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
    });

    Future<String> transform(String content) => htmlTransform.transformToHtml(
      htmlContent: content,
      transformConfiguration: config,
    );

    group('Empty content', () {
      test('SHOULD return a document without script or event handlers for empty input', () async {
        final out = await transform('');
        expect(out, isNot(contains('<script')));
        expect(out, isNot(contains('onerror')));
      });
    });

    group('Simple HTML preservation', () {
      test('SHOULD preserve text content from a simple paragraph', () async {
        expect(await transform(HtmlEmailCorpus.htmlSimple), contains('Hello World'));
      });

      test('SHOULD preserve bold text and https hyperlink', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithBoldAndLink);
        expect(out, allOf(contains('Hello'), contains('World')));
        expect(out, contains('href="https://example.com"'));
      });

      test('SHOULD preserve Unicode, emoji, and accented characters', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithUnicode);
        expect(out, allOf(contains('🎉'), contains('résumé'), contains('日本語')));
      });
    });

    group('XSS blocking', () {
      test('SHOULD remove <script> tag while preserving surrounding text', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithScriptTag);
        expect(out, isNot(contains('<script')));
        expect(out, allOf(contains('Before'), contains('After')));
      });

      test('SHOULD remove onerror event attribute from <img>', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithImgOnerror);
        expect(out, isNot(contains('onerror')));
        expect(out, isNot(contains('evil.com')));
      });

      test('SHOULD sanitize javascript: href from <a> tag', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithJavascriptLink);
        expect(out, isNot(contains('javascript:')));
        expect(out, contains('Click me'));
      });

      test('SHOULD remove <iframe> while preserving surrounding content', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithIframe);
        expect(out, isNot(contains('<iframe')));
        expect(out, allOf(contains('Content'), contains('End')));
      });

      test('SHOULD remove phishing form elements', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithFormPhishing);
        expect(out, isNot(contains('<input')));
        expect(out, isNot(contains('attacker.com')));
      });

      test('SHOULD sanitize XSS-rich email while preserving valid content', () async {
        final out = await transform(HtmlEmailCorpus.htmlXssRich);
        expect(out, allOf(
          isNot(contains('<script')),
          isNot(contains('onerror')),
          isNot(contains('onmouseover')),
          contains('Valid content'),
        ));
      });

      test('SHOULD sanitize data: URI href from <a> tag', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithDataUriHref);
        expect(out, isNot(contains('data:text/html')));
      });
    });

    group('Backslash namespace / path patterns in HTML text nodes', () {
      test('SHOULD preserve backslash namespace inside <code> tag', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithBackslashInCode);
        expect(out, contains(r'\App\DB\Exception\AuthFailed'));
        expect(out, contains('access denied'));
      });

      test('SHOULD preserve backslash namespace across multiple HTML text nodes', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithBackslashMultipleNodes);
        expect(out, allOf(contains('NotFound'), contains('Dispatcher')));
      });

      test('SHOULD preserve backslash namespace AND keep clickable <a> link in same email', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithBackslashAndLink);
        expect(out, contains(r'\App\DB\Exception\AuthFailed'));
        expect(out, contains('href="https://docs.example.com/errors"'));
      });

      test('SHOULD preserve Windows file path backslashes inside <code>', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithWindowsPath);
        expect(out, contains(r'C:\Users\Admin'));
        expect(out, contains('error.log'));
      });

      test('SHOULD preserve Go package path with backslash separators', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithGoPath);
        expect(out, allOf(contains(r'\github.com\org\repo'), contains('handler')));
      });
    });

    group('Hyperlink sanitization', () {
      test('SHOULD preserve safe https and mailto hyperlinks', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithMultipleLinks);
        expect(out, allOf(
          contains('href="https://example.com"'),
          contains('href="https://docs.example.com"'),
          contains('href="mailto:support@example.com"'),
        ));
      });

      test('SHOULD sanitize javascript: href in HTML email link', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithJavascriptHref);
        expect(out, isNot(contains('javascript:')));
      });
    });

    group('Complex and nested HTML emails', () {
      test('SHOULD preserve text content from complex nested HTML email', () async {
        final out = await transform(HtmlEmailCorpus.htmlComplexNested);
        expect(out, allOf(
          contains('Monthly Performance Report'),
          contains('Engineering'),
          contains('finance portal'),
        ));
      });

      test('SHOULD preserve hyperlinks in complex HTML email', () async {
        final out = await transform(HtmlEmailCorpus.htmlComplexNested);
        expect(out, contains('href="https://finance.example.com/budget"'));
      });

      test('SHOULD preserve text from deeply nested HTML tags', () async {
        final out = await transform(HtmlEmailCorpus.htmlDeeplyNested);
        expect(out, contains('deeply nested content'));
      });

      test('SHOULD preserve structure of Markdown-rendered HTML email', () async {
        final out = await transform(HtmlEmailCorpus.htmlMarkdownRendered);
        expect(out, allOf(
          contains('Monthly Report'),
          contains('Revenue'),
          contains('href="https://analytics.example.com"'),
        ));
      });
    });

    group('HTML entity encoding', () {
      test('SHOULD keep &lt;script&gt; as escaped text, not execute it', () async {
        final out = await transform(HtmlEmailCorpus.htmlWithEncodedEntities);
        expect(out, isNot(contains('<script>')));
      });

      test('SHOULD preserve double-encoded HTML entities as safe text', () async {
        final out = await transform(HtmlEmailCorpus.htmlDoubleEncoded);
        expect(out, isNot(contains('<script>')));
      });
    });

    group('Multi-language and RTL content', () {
      test('SHOULD preserve RTL Arabic content', () async {
        final out = await transform(HtmlEmailCorpus.htmlRtlArabic);
        expect(out, contains('مرحبا'));
      });

      test('SHOULD preserve CJK content across multiple HTML paragraphs', () async {
        final out = await transform(HtmlEmailCorpus.htmlCjk);
        expect(out, allOf(contains('日本語'), contains('中文'), contains('한국어')));
      });
    });
  });

  group('HtmlTransform.transformToHtml — fromDomTransformers', () {
    late HtmlTransform htmlTransform;

    setUp(() {
      htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
    });

    Future<String> transformWith(
      String content,
      List<DomTransformer> domTransformers,
    ) =>
        htmlTransform.transformToHtml(
          htmlContent: content,
          transformConfiguration:
              TransformConfiguration.fromDomTransformers(domTransformers),
        );

    group('Empty transformer list', () {
      test('SHOULD leave <script> tag intact when no DOM transformers are specified', () async {
        final out = await transformWith(HtmlEmailCorpus.htmlWithScriptTag, []);
        expect(out, contains('<script'));
        expect(out, allOf(contains('Before'), contains('After')));
      });

      test('SHOULD leave javascript: href intact when no DOM transformers are specified', () async {
        final out = await transformWith(HtmlEmailCorpus.htmlWithJavascriptLink, []);
        expect(out, contains('javascript:'));
        expect(out, contains('Click me'));
      });
    });

    group('Single transformer isolation', () {
      test('SHOULD remove <script> but not add target/rel to links when only RemoveScriptTransformer is used', () async {
        const input =
            HtmlEmailCorpus.htmlWithScriptTag + HtmlEmailCorpus.htmlWithBoldAndLink;
        final out = await transformWith(input, [const RemoveScriptTransformer()]);
        expect(out, allOf(
          isNot(contains('<script')),
          contains('Before'),
          contains('After'),
          contains('Hello'),
          isNot(contains('target="_blank"')),
          isNot(contains('rel="noreferrer"')),
        ));
      });

      test('SHOULD add target="_blank" and rel="noreferrer" to links but not remove <script> when only SanitizeHyperLinkTagInHtmlTransformer is used', () async {
        const input =
            HtmlEmailCorpus.htmlWithScriptTag + HtmlEmailCorpus.htmlWithBoldAndLink;
        final out = await transformWith(input, [SanitizeHyperLinkTagInHtmlTransformer()]);
        expect(out, allOf(
          contains('<script'),
          contains('href="https://example.com"'),
          contains('target="_blank"'),
          contains('rel="noreferrer"'),
        ));
      });
    });

    group('Multiple transformers combined', () {
      test('SHOULD apply all specified transformers simultaneously', () async {
        const input =
            HtmlEmailCorpus.htmlWithScriptTag + HtmlEmailCorpus.htmlWithBoldAndLink;
        final out = await transformWith(
          input,
          [const RemoveScriptTransformer(), SanitizeHyperLinkTagInHtmlTransformer()],
        );
        expect(out, allOf(
          isNot(contains('<script')),
          contains('href="https://example.com"'),
          contains('target="_blank"'),
          contains('Before'),
          contains('After'),
          contains('Hello'),
        ));
      });
    });

    group('No text-transformer preprocessing', () {
      test('SHOULD preserve backslash namespace inside <code> without text preprocessing', () async {
        final out = await transformWith(
          HtmlEmailCorpus.htmlWithBackslashInCode,
          [const RemoveScriptTransformer(), SanitizeHyperLinkTagInHtmlTransformer()],
        );
        expect(out, contains(r'\App\DB\Exception\AuthFailed'));
        expect(out, contains('access denied'));
      });

      test('SHOULD preserve Windows file path without text preprocessing', () async {
        final out = await transformWith(
          HtmlEmailCorpus.htmlWithWindowsPath,
          [const RemoveScriptTransformer(), SanitizeHyperLinkTagInHtmlTransformer()],
        );
        expect(out, contains(r'C:\Users\Admin'));
        expect(out, contains('error.log'));
      });
    });
  });
}
