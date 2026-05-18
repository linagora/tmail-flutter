import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/text/new_line_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_autolink_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_plain_text_html_output_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:uuid/uuid.dart';

import 'calendar_event_description_transform_test.mocks.dart';

// DioClient: required by HtmlTransform constructor; not called for text-transformer-only path.
// FileUploader, Uuid: required by HtmlAnalyzer constructor; not called in these tests.
@GenerateNiceMocks([
  MockSpec<DioClient>(),
  MockSpec<FileUploader>(),
  MockSpec<Uuid>(),
])
void main() {
  group('Calendar event description transformation pipeline', () {
    late HtmlAnalyzer htmlAnalyzer;

    setUp(() {
      htmlAnalyzer = HtmlAnalyzer(
        HtmlTransform(MockDioClient(), const HtmlEscape()),
        MockFileUploader(),
        MockUuid(),
      );
    });

    // Applies the same transformer chain as _parseCalendarEventAction.
    Future<String> transformDescription(String description) =>
        htmlAnalyzer.transformHtmlEmailContent(
          description,
          TransformConfiguration.create(
            customTextTransformers: const [
              SanitizeAutolinkHtmlTransformers(),
              SanitizePlainTextHtmlOutputTransformer(),
              NewLineTransformer(),
            ],
          ),
        );

    group('Backslash-hex patterns — regression for \\XX false-positive', () {
      test('SHOULD NOT blank out an ICS description with PHP namespace separators', () async {
        // ICS DESCRIPTION: "Server path: \Corp\DAV\Server\Exception\Forbidden"
        // Before fix: the pipeline used escapeHtml:false + StandardizeHtmlSanitizingTransformers.
        // \DA in a PHP-style namespace matched unicodeEscapeReg and stripped the entire text node → blank output.
        const description = r'Meeting exception: \Corp\DAV\Server\Exception\Forbidden — contact IT';
        final result = await transformDescription(description);
        expect(result, contains(r'\Corp\DAV\Server\Exception'));
        expect(result, contains('contact IT'));
      });

      test('SHOULD preserve Windows file path separators in ICS description', () async {
        const description = r'Attachment saved at: C:\Users\Admin\Documents\invite.pdf';
        final result = await transformDescription(description);
        expect(result, contains(r'C:\Users\Admin\Documents'));
      });

      test('SHOULD preserve Go package path with backslash separators', () async {
        // The linkifier may recognise domain segments (e.g. github.com) and
        // autolink them; individual path segments must still be present.
        const description = r'Build error in \github.com\org\repo\pkg\handler\main.go line 42';
        final result = await transformDescription(description);
        expect(result, contains('org'));
        expect(result, contains('repo'));
        expect(result, contains('pkg'));
        expect(result, contains('handler'));
      });
    });

    group('XSS blocking — ICS description injection attacks', () {
      test('SHOULD block <script> tag embedded in ICS description', () async {
        const description = 'Meeting notes: <script>document.cookie</script>';
        final result = await transformDescription(description);
        expect(result, isNot(contains(RegExp(r'<script\b', caseSensitive: false))));
        expect(result, contains('Meeting notes'));
      });

      test('SHOULD neutralise event handler injection — <img> becomes HTML-escaped text', () async {
        // SanitizeAutolinkHtmlTransformers (escapeHtml: true) converts < and >
        // to &lt; / &gt; before any parsing, so the <img onerror=...> tag can
        // never be interpreted as an element. The text "onerror" may still appear
        // in the escaped representation, but it cannot execute.
        const description = '<img src="x" onerror="alert(1)"> Team photo';
        final result = await transformDescription(description);
        expect(result, isNot(contains(RegExp(r'<img\b', caseSensitive: false))));
        expect(result, contains('Team photo'));
      });

      test('SHOULD HTML-escape < and > so they render as text, not markup', () async {
        const description = 'Status: a < b && b > 0';
        final result = await transformDescription(description);
        expect(result, contains('&lt;'));
        expect(result, contains('&gt;'));
      });
    });

    group('URL autolinking', () {
      test('SHOULD convert https URL in ICS description to a clickable <a> link', () async {
        const description = 'Join at https://meet.example.com/room/123';
        final result = await transformDescription(description);
        expect(result, contains('href="https://meet.example.com/room/123"'));
      });

      test('SHOULD convert email address in ICS description to a mailto: link', () async {
        const description = 'Contact: organizer@example.com for questions';
        final result = await transformDescription(description);
        expect(result, contains('mailto:'));
        expect(result, contains('organizer@example.com'));
      });

      test(
        'SHOULD autolink URL and preserve backslash namespace in the same ICS description',
        () async {
          const description =
              r'Error \App\DB\Exception\AuthFailed — see https://jira.example.com/ISSUE-99 for fix';
          final result = await transformDescription(description);
          expect(result, contains(r'\App\DB\Exception\AuthFailed'));
          expect(result, contains('href="https://jira.example.com/ISSUE-99"'));
        },
      );
    });

    group('Newline handling', () {
      test('SHOULD convert \\n newlines to <br> for display in webview', () async {
        const description = 'Agenda:\n1. Intro\n2. Demo\n3. Q&A';
        final result = await transformDescription(description);
        expect(result, contains('<br>'));
        expect(result, contains('Intro'));
        expect(result, contains('Q&amp;A'));
      });

      test('SHOULD handle multi-line ICS description with backslash patterns and URLs', () async {
        const description =
            r'Exception: \App\DB\Exception\Forbidden' '\n'
            'See https://docs.example.com/errors\n'
            'Contact: admin@example.com';
        final result = await transformDescription(description);
        expect(result, contains(r'\App\DB\Exception\Forbidden'));
        expect(result, contains('href="https://docs.example.com/errors"'));
        expect(result, contains('mailto:'));
        expect(result, contains('<br>'));
      });
    });

    group('Unicode and plain text', () {
      test('SHOULD preserve Unicode characters in ICS description', () async {
        const description = 'Réunion d\'équipe 🗓 — Café au lait après 日本語 discussion';
        final result = await transformDescription(description);
        expect(result, contains('Réunion'));
        expect(result, contains('🗓'));
        expect(result, contains('日本語'));
      });

      test('SHOULD produce an empty body for an empty ICS description', () async {
        // transformHtmlEmailContent wraps output in an HTML document skeleton;
        // an empty description must leave the body element empty.
        final result = await transformDescription('');
        expect(result, contains('<body></body>'));
      });
    });
  });
}
