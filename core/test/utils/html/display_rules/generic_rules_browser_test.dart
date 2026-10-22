@TestOn('chrome')
@Tags(['display'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/html_emails/html_email_corpus_fixture.dart';
import '../display_harness/display_case.dart';
import '../display_harness/known_display_failures.dart';
import 'generic_rules.dart';
import 'surface_rules.dart';

/// Every generic rule on every fixture, viewer and email pane width (again
/// with any trimmed quote expanded); a case reports all its violations.
void main() {
  group('rules catch what the reviewer probed', () {
    Future<List<Violation>> violationsFor(
      HtmlEmailCorpusFixture fixture, {
      int width = 296,
      DisplayMutation? mutation,
    }) async {
      final displayCase = DisplayCase(fixture, DisplayViewer.ios, width);
      final render = await renderDisplayCase(displayCase, mutation: mutation);
      try {
        return await runGenericRules(render);
      } finally {
        render.dispose();
      }
    }

    Future<List<Violation>> violationsOf(String html, {int width = 296}) =>
        violationsFor(
          HtmlEmailCorpusFixture(name: 'probe', category: 'rules', html: html),
          width: width,
        );

    List<String> described(List<Violation> violations) =>
        [for (final v in violations) '${v.rule} ${v.path} ${v.detail}'];

    test('G-overflow catches text that runs past its box', () async {
      final violations = await violationsOf(
        '<p style="white-space:nowrap">${'word ' * 200}</p>',
      );
      expect(violations.map((v) => v.rule), contains('G-overflow'));
    });

    test('G-link-fill catches a stretched file card', () async {
      final violations = await violationsOf(
        '<a class="tmail-file-link-card" href="https://x.example/f" '
        'style="display:inline-block;width:183px !important;min-width:250px">f</a>',
      );
      expect(violations.map((v) => v.rule), contains('G-link-fill'));
    });

    test('G-image-fit catches an image squashed out of its ratio', () async {
      final violations = await violationsOf(
        '<style>img { height: 20px !important; }</style>'
        '<img src="https://fixture.invalid/img/200x100" width="200" height="100">',
      );
      expect(described(violations), [
        'G-image-fit .tmail-content > img aspect 10.00, expected 2.00 or 2.00',
      ]);
    });

    test('G-text catches an email that shows nothing', () async {
      expect(described(await violationsOf('<p></p>')), [
        'G-text .tmail-content nothing visible',
      ]);
    });

    test('G-text accepts an empty email its fixture allows', () async {
      final violations = await violationsFor(const HtmlEmailCorpusFixture(
        name: 'probe',
        category: 'rules',
        html: '<p></p>',
        allowEmptyBody: true,
      ));
      expect(violations, isEmpty);
    });

    test('G-rtl catches a right-to-left email rendered without dir="rtl"', () async {
      const fixture = HtmlEmailCorpusFixture(
        name: 'probe',
        category: 'rules',
        html: '<p>مرحبا</p>',
        rtl: true,
      );
      expect(await violationsFor(fixture), isEmpty);
      final violations = await violationsFor(
        fixture,
        mutation: DisplayMutation(
          document: (document) => document.replaceFirst('<body dir="rtl"', '<body'),
        ),
      );
      expect(described(violations), ['G-rtl body dir=""']);
    });

    test('G-text looks inside a collapsed quote', () async {
      const displayCase = DisplayCase(
        HtmlEmailCorpusFixture(
          name: 'quote_only',
          category: 'rules',
          html: '<blockquote><p>Only quoted text.</p></blockquote>',
        ),
        DisplayViewer.native,
        390,
      );
      final render = await renderDisplayCase(displayCase);
      try {
        expect(await runGenericRules(render), isEmpty);
        expect(render.frame.isQuoteExpanded, isTrue);
      } finally {
        render.dispose();
      }
    });
  });

  for (final displayCase in displayCases()) {
    test(
      displayCase.label,
      () async {
        await withDisplayCase(displayCase, (render) async {
          final violations = [
            ...await runGenericRules(render),
            ...runSurfaceRules(render),
          ];
          expect(
            violations.map((v) => v.describe(displayCase)).toList(),
            isEmpty,
          );
        });
      },
      skip: knownDisplayFailures[displayCase.label],
    );
  }
}
