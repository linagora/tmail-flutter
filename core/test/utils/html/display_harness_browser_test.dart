@TestOn('chrome')
@Tags(['display'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/html_emails/html_email_corpus_fixture.dart';
import 'display_harness/display_case.dart';

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

  test('labels failures as <category>/<fixture> @<viewer> <W>px', () {
    final displayCase = caseFor('<p>x</p>', viewer: DisplayViewer.web, width: 760);
    expect(
      displayCase.failure('no horizontal overflow', '.tmail-content > table', '+12.0px'),
      'harness/probe @web 760px: no horizontal overflow: .tmail-content > table +12.0px',
    );
  });
}
