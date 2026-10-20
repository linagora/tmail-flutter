@TestOn('chrome')
@Tags(['display'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

import '../../fixtures/html_emails/html_email_corpus_fixture.dart';
import 'display_harness/display_case.dart';
import 'display_harness/known_display_failures.dart';
import 'display_rules/expect_checkers.dart';

/// The harness itself: what it reports must point at the right element.
void main() {
  DisplayCase caseFor(String html, {DisplayViewer viewer = DisplayViewer.ios, int width = 336}) =>
      DisplayCase(
        HtmlEmailCorpusFixture(name: 'probe', category: 'harness', html: html),
        viewer,
        width,
      );

  test('reports the CSS path and pixels of an element past the pane', () async {
    await withDisplayCase(
      caseFor('<p>ok</p><div><p>a</p><p><span style="display:inline-block;width:500px">wide</span></p></div>'),
      (render) async {
        final frame = render.frame;
        final overflows = frame.overflows();
        expect(overflows, isNotEmpty);
        final span = overflows.singleWhere((o) => o.path.endsWith('span'));
        expect(span.path, '.tmail-content > div > p:nth-of-type(2) > span');
        final expected = frame.query('span')!.getBoundingClientRect().right -
            frame.content.getBoundingClientRect().right;
        expect(span.pixels, closeTo(expected, 0.5));
        expect(span.pixels, greaterThan(100));
      },
    );
  });

  test('reports content that sticks out on the left in a right-to-left email', () async {
    await withDisplayCase(
      const DisplayCase(
        HtmlEmailCorpusFixture(
          name: 'rtl',
          category: 'harness',
          html: '<div style="width:500px">عريض</div>',
          rtl: true,
        ),
        DisplayViewer.ios,
        336,
      ),
      (render) async {
        final div = render.frame.overflows().singleWhere((o) => o.path.endsWith('div'));
        expect(div.pixels, greaterThan(100));
      },
    );
  });

  test('builds the document for the width the app passes, not the pane', () {
    final native = DisplayViewer.native.buildDocument('<p>x</p>', 336);
    expect(native, matches(RegExp(r'const displayWidth = 360(\.0)?;')));
    final web = DisplayViewer.web.buildDocument('<p>x</p>', 760);
    expect(web, matches(RegExp(r'const displayWidth = 792(\.0)?;')));
  });

  test('renders a fixture placeholder as an offline image of its size', () async {
    await withDisplayCase(
      caseFor('<img src="https://fixture.invalid/img/120x40" alt="p">'),
      (render) async {
        final image = render.frame.images.single;
        expect(image.element.src, startsWith('data:image/svg+xml'));
        expect((image.naturalWidth, image.naturalHeight), (120, 40));
        expect(render.transformedHtml, contains('https://fixture.invalid/img/120x40'));
      },
    );
  });

  test('a plain-text fixture goes through the plain-text pipeline', () async {
    await withDisplayCase(
      const DisplayCase(
        HtmlEmailCorpusFixture(
          name: 'plain',
          category: 'harness',
          html: 'Hi <b>there</b> https://example.com/a',
          contentType: HtmlEmailCorpusFixture.plainTextContentType,
        ),
        DisplayViewer.native,
        390,
      ),
      (render) async {
        expect(render.transformedHtml, contains('&lt;b&gt;'));
        expect(render.frame.visibleText, contains('Hi <b>there</b>'));
        expect(render.frame.query('a'), isNotNull);
      },
    );
  });

  test('every known display failure names a test that exists', () {
    final names = {
      for (final displayCase in displayCases()) ...[
        displayCase.label,
        for (final label in displayCase.fixture.expect)
          if (expectApplies(label, displayCase.viewer))
            '${displayCase.label} expect ${label.name}',
      ],
    };
    expect(knownDisplayFailures.keys.toSet().difference(names), isEmpty);
  });

  test('fails a render that fetches anything outside the test server', () async {
    final origin = web.window.location.origin;
    final other = origin.contains('localhost')
        ? origin.replaceFirst('localhost', '127.0.0.1')
        : origin.replaceFirst('127.0.0.1', 'localhost');
    await expectLater(
      DisplayFrame.render(
        '<html><body><div class="tmail-content"><img src="$other/probe.png"></div></body></html>',
        336,
        label: 'probe',
      ),
      throwsA(isA<StateError>().having((e) => e.message, 'message', contains('/probe.png'))),
    );
  });

  test('fails when expanding a quote fetches something outside the test server', () async {
    final origin = web.window.location.origin;
    final other = origin.contains('localhost')
        ? origin.replaceFirst('localhost', '127.0.0.1')
        : origin.replaceFirst('127.0.0.1', 'localhost');
    final frame = await DisplayFrame.render(
      '<html><body><div class="tmail-content">'
      '<button class="quote-toggle-button" onclick="'
      "this.nextElementSibling.style.display='block'; new Image().src='$other/deferred.png'\">"
      'toggle</button>'
      '<blockquote style="display:none">quoted</blockquote>'
      '</div></body></html>',
      336,
      label: 'deferred',
    );
    addTearDown(frame.dispose);
    await expectLater(
      frame.toggleQuote(),
      throwsA(isA<StateError>().having((e) => e.message, 'message', contains('/deferred.png'))),
    );
  });

  test('labels failures as <category>/<fixture> @<viewer> <W>px', () {
    final displayCase = caseFor('<p>x</p>', viewer: DisplayViewer.web, width: 760);
    expect(
      displayCase.failure('no horizontal overflow', '.tmail-content > table', '+12.0px'),
      'harness/probe @web 760px: no horizontal overflow: .tmail-content > table +12.0px',
    );
  });
}
