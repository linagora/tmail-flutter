import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/dom/autolink_text_node_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/sanitize_hyper_link_tag_in_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;

class _FakeDioClient extends Fake implements DioClient {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<String> _run(AutolinkTextNodeTransformer transformer, String html,
    {DioClient? dioClient}) async {
  final document = html_parser.parse(html);
  await transformer.process(
    document: document,
    dioClient: dioClient ?? _FakeDioClient(),
  );
  return document.body!.innerHtml;
}

// Generates n levels of nested <div> wrapping [inner].
String _nested(int depth, String inner) =>
    '${'<div>' * depth}$inner${'</div>' * depth}';

void main() {
  group('AutolinkTextNodeTransformer', () {
    late AutolinkTextNodeTransformer transformer;

    setUp(() {
      transformer = const AutolinkTextNodeTransformer();
    });

    Future<String> transform(String html) => _run(transformer, html);

    // -----------------------------------------------------------------------
    // 1. URL autolinking — core behaviour
    // -----------------------------------------------------------------------
    group('URL autolinking', () {
      test('SHOULD linkify a bare https URL in plain text', () async {
        final result = await transform('Join at https://meet.example.com/room');
        expect(result, contains('href="https://meet.example.com/room"'));
        expect(result, contains('Join at'));
      });

      test('SHOULD linkify a bare http URL', () async {
        final result = await transform('See http://example.com today');
        expect(result, contains('href="http://example.com"'));
      });

      test('SHOULD linkify a www URL and default it to https', () async {
        final result = await transform('Visit www.linagora.com for info');
        expect(result, contains('href="https://www.linagora.com"'));
      });

      test('SHOULD strip www from the visible link text', () async {
        // removeWww: true — the anchor text must not start with "www."
        final result = await transform('Visit www.linagora.com today');
        expect(result, contains('>linagora.com<'));
      });

      test('SHOULD add target=_blank and rel=noreferrer to autolinked URL anchors', () async {
        final result = await transform('https://example.com');
        expect(result, contains('target="_blank"'));
        expect(result, contains('rel="noreferrer"'));
      });

      test('SHOULD apply inline style to autolinked URL anchors', () async {
        final result = await transform('https://example.com');
        expect(result, contains('white-space: nowrap'));
        expect(result, contains('word-break: keep-all'));
      });

      test('SHOULD preserve surrounding text alongside an autolinked URL', () async {
        final result = await transform('Before https://example.com after');
        expect(result, contains('Before '));
        expect(result, contains(' after'));
        expect(result, contains('href="https://example.com"'));
      });

      test('SHOULD linkify a URL that contains a query string', () async {
        final result = await transform(
          'See https://example.com/search?q=hello+world&lang=en for results',
        );
        expect(result, contains('href="https://example.com/search'));
      });

      test('SHOULD linkify a URL inside a <p> element text node', () async {
        final result = await transform('<p>Join at https://meet.example.com/9</p>');
        expect(result, contains('href="https://meet.example.com/9"'));
        expect(result, contains('<p>'));
      });
    });

    // -----------------------------------------------------------------------
    // 2. Email autolinking
    // -----------------------------------------------------------------------
    group('Email autolinking', () {
      test('SHOULD wrap email address in a mailto anchor', () async {
        final result = await transform('Contact admin@example.com for help');
        expect(result, contains('href="mailto:admin@example.com"'));
        expect(result, contains('Contact'));
        expect(result, contains('for help'));
      });

      test('SHOULD NOT add target=_blank on mailto anchors', () async {
        final result = await transform('admin@example.com');
        // Extract just the <a> tag before </a>
        final start = result.indexOf('<a ');
        final end = result.indexOf('</a>');
        final anchorTag = result.substring(start, end);
        expect(anchorTag, isNot(contains('target="_blank"')));
      });

      test('SHOULD apply inline style to mailto anchors', () async {
        final result = await transform('admin@example.com');
        expect(result, contains('white-space: nowrap'));
      });
    });

    // -----------------------------------------------------------------------
    // 3. Multiple links in a single text node
    // -----------------------------------------------------------------------
    group('Multiple links in one text node', () {
      test('SHOULD linkify two https URLs in one text node', () async {
        final result = await transform(
          'See https://example.com and https://other.com for details',
        );
        expect(result, allOf(
          contains('href="https://example.com"'),
          contains('href="https://other.com"'),
          contains('See '),
          contains(' and '),
          contains(' for details'),
        ));
      });

      test('SHOULD linkify a URL and an email in the same text node', () async {
        final result = await transform(
          'Join https://meet.example.com or contact admin@example.com',
        );
        expect(result, contains('href="https://meet.example.com"'));
        expect(result, contains('href="mailto:admin@example.com"'));
      });

      test('SHOULD linkify all three URLs in one element', () async {
        // Uses a <p> wrapper so the text node is a proper DOM child — verifies
        // that each URL in a mixed text node is individually linkified.
        final result = await transform(
          '<p>https://first.example.com https://second.example.com https://third.example.com</p>',
        );
        expect(result, contains('href="https://first.example.com"'));
        expect(result, contains('href="https://second.example.com"'));
        expect(result, contains('href="https://third.example.com"'));
      });
    });

    // -----------------------------------------------------------------------
    // 4. HTML structure preservation — skip-tag behaviour
    // -----------------------------------------------------------------------
    group('HTML structure preservation — skip tags', () {
      test('SHOULD NOT re-linkify URL inside existing <a> href attribute', () async {
        final result = await transform('<a href="https://example.com">Visit</a>');
        expect(result, contains('href="https://example.com"'));
        // Must not nest a second <a> inside the first one
        expect(result, isNot(contains('href="https://example.com"><a')));
        expect(result, isNot(contains('href="<a')));
      });

      test('SHOULD NOT re-linkify URL that is the visible text of an existing <a>', () async {
        final result = await transform(
          '<a href="https://example.com/a">https://example.com/a</a>',
        );
        expect(result, contains('href="https://example.com/a"'));
        expect(result, isNot(contains('href="<a')));
      });

      test('SHOULD NOT linkify content inside <script>', () async {
        final result = await transform(
          '<script>var url = "https://example.com";</script>',
        );
        expect(result, isNot(contains('<a href')));
      });

      test('SHOULD NOT linkify content inside <style>', () async {
        final result = await transform(
          '<style>div::after { content: "https://example.com" }</style>',
        );
        expect(result, isNot(contains('<a href')));
      });

      test('SHOULD NOT linkify content inside <textarea>', () async {
        final result = await transform(
          '<textarea>https://example.com admin@example.com</textarea>',
        );
        expect(result, isNot(contains('<a href')));
      });

      test('SHOULD skip entire <a> subtree including nested elements', () async {
        // Deeply nested element inside <a> must not get re-linkified
        final result = await transform(
          '<a href="https://example.com"><span><b>https://example.com</b></span></a>',
        );
        // Only one <a> tag in the output
        expect(RegExp(r'<a ').allMatches(result).length, equals(1));
      });

      test('SHOULD linkify text outside skip-tag elements that are siblings', () async {
        // URL before the <a> and after it must both be linkified; content inside must not
        final result = await transform(
          'https://before.com <a href="https://inside.com">Inside</a> https://after.com',
        );
        expect(result, contains('href="https://before.com"'));
        expect(result, contains('href="https://after.com"'));
        // inside.com URL stays as the original href only
        final insideHrefCount =
            RegExp('href="https://inside.com"').allMatches(result).length;
        expect(insideHrefCount, equals(1)); // only the original href
      });
    });

    // -----------------------------------------------------------------------
    // 5. Coexistence with sibling elements in same parent
    // -----------------------------------------------------------------------
    group('Sibling element coexistence', () {
      test('SHOULD linkify text mixed with <b> sibling elements', () async {
        final result =
            await transform('<p>See <b>details</b> at https://example.com</p>');
        expect(result, contains('<p>'));
        expect(result, contains('<b>'));
        expect(result, contains('href="https://example.com"'));
      });

      test('SHOULD preserve <br> tags while linkifying text between them', () async {
        final result =
            await transform('Before<br>https://example.com<br>After');
        expect(result, allOf(
          contains('<br>'),
          contains('href="https://example.com"'),
          contains('Before'),
          contains('After'),
        ));
      });

      test('SHOULD linkify text nodes adjacent to <img> without corrupting src', () async {
        final result = await transform(
          '<img src="https://cdn.example.com/img.png"> caption https://example.com',
        );
        // The img src must survive unchanged
        expect(result, contains('src="https://cdn.example.com/img.png"'));
        // The text URL must be linkified
        expect(result, contains('href="https://example.com"'));
      });
    });

    // -----------------------------------------------------------------------
    // 6. Deeply nested HTML — recursive DOM walk
    // -----------------------------------------------------------------------
    group('Deeply nested HTML', () {
      test('SHOULD linkify a URL inside 10 levels of nesting', () async {
        final result = await transform(_nested(10, 'https://example.com'));
        expect(result, contains('href="https://example.com"'));
      });

      test('SHOULD linkify a URL inside 30 levels of nesting without stack overflow', () async {
        final result = await transform(_nested(30, 'https://example.com'));
        expect(result, contains('href="https://example.com"'));
      });

      test('SHOULD preserve all HTML structure around a deeply nested URL', () async {
        const html = '<table><tr><td><p><span>https://deep.example.com</span></p></td></tr></table>';
        final result = await transform(html);
        expect(result, allOf(
          contains('href="https://deep.example.com"'),
          contains('<table>'),
          contains('<td>'),
          contains('<span>'),
        ));
      });
    });

    // -----------------------------------------------------------------------
    // 7. DOM mutation safety — toList() guard
    // -----------------------------------------------------------------------
    group('DOM mutation safety', () {
      test('SHOULD handle multiple text nodes in same parent without error', () async {
        // Two text nodes (created by <b> splitting the parent) both get modified.
        // The toList() snapshot in _linkifyNode prevents ConcurrentModificationError.
        final result = await transform(
          '<p>https://alpha.example.com <b>bold</b> https://beta.example.com</p>',
        );
        expect(result, contains('href="https://alpha.example.com"'));
        expect(result, contains('href="https://beta.example.com"'));
        expect(result, contains('<b>'));
      });

      test('SHOULD handle many text nodes in one parent without error', () async {
        // 10 text-node siblings all containing a URL
        final spans =
            List.generate(10, (i) => 'https://example$i.com ').join('');
        final result = await transform('<p>$spans</p>');
        for (var i = 0; i < 10; i++) {
          expect(result, contains('href="https://example$i.com"'));
        }
      });
    });

    // -----------------------------------------------------------------------
    // 8. Real-world calendar event HTML formats
    // -----------------------------------------------------------------------
    group('Real-world calendar event HTML', () {
      test('SHOULD preserve a Zoom join link and linkify a bare URL in the same description', () async {
        const html =
            '<p><a href="https://zoom.us/j/123456789">Join Zoom Meeting</a></p>'
            '<p>Conference room: https://rooms.example.com/conf-a</p>';
        final result = await transform(html);
        // Original Zoom link preserved
        expect(result, contains('href="https://zoom.us/j/123456789"'));
        expect(result, contains('Join Zoom Meeting'));
        // Bare URL linkified
        expect(result, contains('href="https://rooms.example.com/conf-a"'));
      });

      test('SHOULD handle Google Meet invitation format', () async {
        const html = '<p>Join with Google Meet</p>'
            '<p><a href="https://meet.google.com/abc-defg-hij">'
            'https://meet.google.com/abc-defg-hij</a></p>'
            '<p>Or dial: +1-555-0100 PIN: 123456</p>';
        final result = await transform(html);
        // The meet URL appears exactly once as the href (not re-linkified into the anchor text)
        expect(
          RegExp('href="https://meet.google.com/abc-defg-hij"')
              .allMatches(result)
              .length,
          equals(1),
        );
        expect(result, contains('+1-555-0100'));
      });

      test('SHOULD linkify a bare URL embedded between HTML elements in a multi-section description', () async {
        const html = '<h3>Agenda</h3>'
            '<ul><li>Welcome</li><li>Demo: https://demo.example.com/live</li></ul>'
            '<p>Slides: <a href="https://slides.example.com">here</a></p>';
        final result = await transform(html);
        expect(result, allOf(
          contains('href="https://demo.example.com/live"'),
          contains('href="https://slides.example.com"'),
          contains('<h3>'),
          contains('<ul>'),
        ));
      });

      test('SHOULD linkify organizer email and join URL in typical invite body', () async {
        const html = '<p>Organizer: organizer@company.com</p>'
            '<p>Join at https://meet.company.com/weekly-sync</p>';
        final result = await transform(html);
        expect(result, contains('href="mailto:organizer@company.com"'));
        expect(result, contains('href="https://meet.company.com/weekly-sync"'));
      });

      test('SHOULD preserve HTML entities and not double-encode them', () async {
        const html = '<p>Status: a &amp; b, priority &lt;high&gt;</p>';
        final result = await transform(html);
        // Entities must stay encoded, not become raw < or &
        expect(result, contains('&amp;'));
        expect(result, contains('&lt;'));
        expect(result, isNot(contains('&&amp;')));
      });
    });

    // -----------------------------------------------------------------------
    // 9. Edge cases
    // -----------------------------------------------------------------------
    group('Edge cases', () {
      test('SHOULD return unchanged output for text with no URLs or emails', () async {
        final result = await transform('<p>Hello world, no links here</p>');
        expect(result, contains('Hello world, no links here'));
        expect(result, isNot(contains('<a href')));
      });

      test('SHOULD handle empty body without throwing', () async {
        final result = await transform('');
        expect(result, isEmpty);
      });

      test('SHOULD handle document with only whitespace text nodes', () async {
        final result = await transform('<p>   </p>');
        expect(result, isNotNull);
        expect(result, isNot(contains('<a href')));
      });

      test('SHOULD handle Unicode content without corrupting characters', () async {
        // linkify only supports ASCII email local parts, so use ASCII email
        const html = '<p>Réunion: https://meet.example.com — contact info@exemple.fr</p>';
        final result = await transform(html);
        // Unicode surrounding text must survive intact
        expect(result, contains('Réunion'));
        // URL and ASCII email must be linkified
        expect(result, contains('href="https://meet.example.com"'));
        expect(result, contains('mailto:info@exemple.fr'));
      });

      test('SHOULD produce no <a> tags for a document with only element nodes', () async {
        // No text nodes at all — only nested elements
        final result = await transform('<div><span></span><p><b></b></p></div>');
        expect(result, isNot(contains('<a href')));
      });
    });

    // -----------------------------------------------------------------------
    // 10. Performance — large document
    // -----------------------------------------------------------------------
    group('Performance', () {
      test('SHOULD process 200 <p> elements each containing a URL within 3 seconds', () async {
        final html = List.generate(
          200,
          (i) => '<p>Item $i: https://example.com/item/$i</p>',
        ).join();

        final stopwatch = Stopwatch()..start();
        final result = await transform(html);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
            reason: 'Large document must not be slow');
        // Spot-check first and last link
        expect(result, contains('href="https://example.com/item/0"'));
        expect(result, contains('href="https://example.com/item/199"'));
      });

      test('SHOULD process 50 levels of nesting in under 500ms', () async {
        final html = _nested(50, 'https://deep.example.com');

        final stopwatch = Stopwatch()..start();
        final result = await transform(html);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        expect(result, contains('href="https://deep.example.com"'));
      });

      test('SHOULD process a text node with 100 URLs in under 2 seconds', () async {
        final urls =
            List.generate(100, (i) => 'https://example$i.com').join(' ');
        final html = '<p>$urls</p>';

        final stopwatch = Stopwatch()..start();
        final result = await transform(html);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        expect(result, contains('href="https://example0.com"'));
        expect(result, contains('href="https://example99.com"'));
      });
    });

    // -----------------------------------------------------------------------
    // 11. ReDoS immunity — inputs that would hang the old regex
    // -----------------------------------------------------------------------
    // The removed regex was: <(?:[^>"']*|"[^"]*"|'[^']*')*>
    // The alternation group inside * caused catastrophic backtracking on
    // unclosed tags with many quotes. The DOM approach has no such regex.
    group('ReDoS immunity', () {
      test('SHOULD process input with many unmatched double quotes quickly', () async {
        // Old regex: <"""""""""" (no >) → exponential backtracking
        final malicious = '<${"\"" * 50}';
        final stopwatch = Stopwatch()..start();
        final result = await transform(malicious);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(50),
            reason: 'Malformed tag with 50 quotes must not cause backtracking');
        expect(result, isNotNull);
      });

      test('SHOULD process input with alternating single/double quotes quickly', () async {
        // Old regex catastrophic case: <'"'"'"'"... (no >)
        final malicious = '<${"\\'\"" * 40}';
        final stopwatch = Stopwatch()..start();
        final result = await transform(malicious);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(50));
        expect(result, isNotNull);
      });

      test('SHOULD process a 5000-char unclosed tag quickly', () async {
        // A very long unclosed tag with mixed chars that would cause catastrophic
        // backtracking in the alternation: ([^>"']*|"[^"]*"|'[^']*')*
        final malicious = '<${"ab\"cd\'ef" * 500}';
        final stopwatch = Stopwatch()..start();
        final result = await transform(malicious);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100),
            reason: '5000-char unclosed tag must complete in under 100ms');
        expect(result, isNotNull);
      });

      test('SHOULD process 1000 consecutive malformed tags quickly', () async {
        // Burst of many short malformed tags
        final malicious = List.generate(1000, (_) => '<"\'').join();
        final stopwatch = Stopwatch()..start();
        final result = await transform(malicious);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(200));
        expect(result, isNotNull);
      });

      test('SHOULD process deeply quoted attribute-like pattern quickly', () async {
        // Pattern that specifically targets the (A|B|C)* vulnerability:
        // many pairs of quotes that overlap with the [^>"']* alternative
        final attack = '<div ${List.generate(200, (_) => '"attr"').join(" ")}'
            ' '; // no closing >
        final stopwatch = Stopwatch()..start();
        final result = await transform(attack);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(result, isNotNull);
      });
    });

    // -----------------------------------------------------------------------
    // 12. Statelessness — const transformer, static linkifiers
    // -----------------------------------------------------------------------
    group('Statelessness and reuse', () {
      test('SHOULD produce identical results when called twice on the same input', () async {
        const html = '<p>Join https://example.com — contact info@example.com</p>';
        final result1 = await transform(html);
        final result2 = await transform(html);
        expect(result1, equals(result2));
      });

      test('SHOULD be reusable across 50 different documents without state leaking', () async {
        for (var i = 0; i < 50; i++) {
          final result = await transform('<p>https://example$i.com</p>');
          expect(result, contains('href="https://example$i.com"'),
              reason: 'Iteration $i: linkified URL must match the input URL');
          // Previous iterations must not appear
          if (i > 0) {
            expect(result, isNot(contains('https://example${i - 1}.com"')));
          }
        }
      });

      test('SHOULD be a const-constructible transformer (no mutable instance state)', () {
        // Two different const instances must have identical behaviour.
        // This verifies the transformer meets the DomTransformer const contract.
        const AutolinkTextNodeTransformer t1 = AutolinkTextNodeTransformer();
        const AutolinkTextNodeTransformer t2 = AutolinkTextNodeTransformer();
        expect(identical(t1, t2), isTrue,
            reason: 'const constructors with no fields produce identical instances');
      });
    });

    // -----------------------------------------------------------------------
    // 13. TransformConfiguration.forCalendarEvent() wiring guard
    // -----------------------------------------------------------------------
    group('TransformConfiguration.forCalendarEvent() wiring', () {
      test('SHOULD include AutolinkTextNodeTransformer in forCalendarEvent() DOM transformers', () {
        final config = TransformConfiguration.forCalendarEvent();
        expect(
          config.domTransformers.whereType<AutolinkTextNodeTransformer>(),
          isNotEmpty,
          reason: 'forCalendarEvent() must wire AutolinkTextNodeTransformer',
        );
      });

      test('SHOULD NOT include AutolinkTextNodeTransformer in standard DOM transformers', () {
        expect(
          TransformConfiguration.standardDomTransformers
              .whereType<AutolinkTextNodeTransformer>(),
          isEmpty,
          reason: 'The standard pipeline must not run AutolinkTextNodeTransformer',
        );
      });

      test('SHOULD have AutolinkTextNodeTransformer before SanitizeHyperLinkTagInHtmlTransformer in forCalendarEvent()', () {
        final transformers = TransformConfiguration.forCalendarEvent().domTransformers;
        final autolinkIdx = transformers.indexWhere((t) => t is AutolinkTextNodeTransformer);
        final sanitizeIdx = transformers.indexWhere((t) => t is SanitizeHyperLinkTagInHtmlTransformer);
        expect(autolinkIdx, greaterThanOrEqualTo(0),
            reason: 'AutolinkTextNodeTransformer must be in the list');
        expect(sanitizeIdx, greaterThanOrEqualTo(0),
            reason: 'SanitizeHyperLinkTagInHtmlTransformer must be in the list');
        expect(autolinkIdx, lessThan(sanitizeIdx),
            reason: 'AutolinkTextNodeTransformer must come before SanitizeHyperLinkTagInHtmlTransformer');
      });
    });
  });
}
