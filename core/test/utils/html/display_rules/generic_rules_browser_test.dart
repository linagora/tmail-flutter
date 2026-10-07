@TestOn('chrome')
@Tags(['display'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/html_emails/html_email_corpus_fixture.dart';
import '../display_harness/display_case.dart';
import 'generic_rules.dart';

/// Every generic rule on every fixture, viewer and email pane width (again
/// with any trimmed quote expanded); a case reports all its violations.
void main() {
  group('rules catch what the reviewer probed', () {
    Future<List<Violation>> violationsOf(String html, {int width = 296}) async {
      final displayCase = DisplayCase(
        HtmlEmailCorpusFixture(name: 'probe', category: 'rules', html: html),
        DisplayViewer.ios,
        width,
      );
      final render = await renderDisplayCase(displayCase);
      try {
        return await runGenericRules(render);
      } finally {
        render.dispose();
      }
    }

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
    test(displayCase.label, () async {
      await withDisplayCase(displayCase, (render) async {
        final violations = await runGenericRules(render);
        expect(
          violations.map((v) => v.describe(displayCase)).toList(),
          isEmpty,
        );
      });
    });
  }
}
