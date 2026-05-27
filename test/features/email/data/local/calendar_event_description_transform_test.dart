import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/text/new_line_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_autolink_unescape_html_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
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

    Future<String> transformDescription(String description) =>
        htmlAnalyzer.transformHtmlEmailContent(
          description,
          TransformConfiguration.create(
            customTextTransformers: const [
              SanitizeAutolinkUnescapeHtmlTransformer(),
              StandardizeHtmlSanitizingTransformers(),
              NewLineTransformer(),
            ],
          ),
        );

    group('Backslash-hex patterns — regression for \\XX false-positive', () {
      test('SHOULD NOT blank out an ICS description with PHP namespace separators', () async {
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

      test('SHOULD strip event-handler attributes from HTML elements', () async {
        const description = '<img src="x" onerror="alert(1)"> Team photo';
        final result = await transformDescription(description);
        expect(result, isNot(contains('onerror')));
        expect(result, contains('Team photo'));
      });

      test('SHOULD preserve HTML entities in ICS description', () async {
        const description = 'Status: a &lt; b &amp;&amp; b &gt; 0';
        final result = await transformDescription(description);
        expect(result, contains('&lt;'));
        expect(result, contains('&gt;'));
      });
    });

    group('HTML passthrough — HTML descriptions rendered as formatted content', () {
      test('SHOULD preserve an existing HTML link destination and text', () async {
        // Real-world calendar invites embed join links as HTML <a href>.
        const description = '<a href="https://example.com/meeting">Join Zoom</a>';
        final result = await transformDescription(description);
        // The original destination URL must survive intact.
        expect(result, contains('href="https://example.com/meeting"'));
        // The visible link text must survive.
        expect(result, contains('Join Zoom'));
        // The markup must not be mangled into garbage by the linkifier.
        expect(result, isNot(contains('<ahref')));
      });

      test('SHOULD pass through safe HTML tags so they render as formatted content', () async {
        const description = '<p>Welcome to the <b>quarterly review</b></p>';
        final result = await transformDescription(description);
        expect(result, contains('<p>'));
        expect(result, contains('<b>'));
        expect(result, contains('quarterly review'));
        // Verify tags are rendered, not escaped as visible text.
        expect(result, isNot(contains('&lt;p&gt;')));
        expect(result, isNot(contains('&lt;b&gt;')));
      });

      test('SHOULD preserve nested HTML list structure', () async {
        const description = '<ul><li>Item 1</li><li>Item 2</li></ul>';
        final result = await transformDescription(description);
        expect(result, contains('Item 1'));
        expect(result, contains('Item 2'));
      });

      test('SHOULD NOT corrupt an HTML link whose visible text is also a URL', () async {
        // href and anchor text both contain a URL — the linkifier must not
        // double-process the attribute and break the tag.
        const description = '<a href="https://example.com/a">https://example.com/a</a>';
        final result = await transformDescription(description);
        expect(result, contains('href="https://example.com/a"'));
        expect(result, isNot(contains('<ahref')));
      });

      test('SHOULD preserve a URL sitting in an <img> src attribute without mangling text', () async {
        // URL lives in the src attribute, not body text. <img> may be stripped
        // by the sanitizer, but the surrounding description must stay intact.
        const description = '<img src="https://cdn.example.com/a.png"> Team photo';
        final result = await transformDescription(description);
        expect(result, contains('Team photo'));
        expect(result, isNot(contains('<ahref')));
      });

      test('SHOULD autolink a bare URL that appears inside an HTML element', () async {
        // Positive guard: a URL in text content (not an attribute) must still
        // become a clickable link, even when wrapped in an element.
        const description = '<p>Join the call at https://meet.example.com/room/9</p>';
        final result = await transformDescription(description);
        expect(result, contains('href="https://meet.example.com/room/9"'));
        expect(result, contains('<p>'));
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

    // Verify the exact production config factory — forCalendarEvent() uses a
    // custom DOM transformer (SanitizeHyperLinkTagInHtmlTransformer) instead of
    // the standard DOM stack. The cases below guard against regressions where a
    // change to the factory silently breaks the calendar description pipeline.
    group('Production config — TransformConfiguration.forCalendarEvent()', () {
      Future<String> transformWithProductionConfig(String description) =>
          htmlAnalyzer.transformHtmlEmailContent(
            description,
            TransformConfiguration.forCalendarEvent(),
          );

      test('SHOULD preserve existing <a href> through the production DOM transformer', () async {
        const description = '<a href="https://example.com/meeting">Join Zoom</a>';
        final result = await transformWithProductionConfig(description);
        expect(result, contains('href="https://example.com/meeting"'));
        expect(result, contains('Join Zoom'));
      });

      test('SHOULD autolink a bare URL through the production DOM transformer', () async {
        const description = 'Join at https://meet.example.com/room/123';
        final result = await transformWithProductionConfig(description);
        expect(result, contains('href="https://meet.example.com/room/123"'));
      });

      test('SHOULD block XSS in the production config pipeline', () async {
        const description = 'Notes: <script>document.cookie</script>';
        final result = await transformWithProductionConfig(description);
        expect(result, isNot(contains(RegExp(r'<script\b', caseSensitive: false))));
        expect(result, contains('Notes'));
      });
    });
  });
}
