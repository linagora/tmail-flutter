@TestOn('chrome')
@Tags(['display'])
library;

import 'package:core/presentation/constants/constants_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/html_emails/html_email_corpus.g.dart';
import '../../../fixtures/html_emails/html_email_corpus_fixture.dart';
import '../display_harness/display_case.dart';
import 'expect_checkers.dart';

/// Each fixture's sidecar `expect` labels, checked on every viewer and pane
/// width they apply to; each label gets its own fresh render.
void main() {
  test('every expect label has a checker and a fixture that uses it', () {
    expect(expectCheckers.keys.toSet(), HtmlEmailExpect.values.toSet());
    final used = {for (final fixture in htmlEmailCorpus) ...fixture.expect};
    expect(used, HtmlEmailExpect.values.toSet());
  });

  group('fixtures reach the branch they exist for', () {
    HtmlEmailCorpusFixture fixture(String name) =>
        htmlEmailCorpus.singleWhere((f) => f.category == 'expect_checks' && f.name == name);

    Future<void> onNative(
      String name,
      Iterable<int> widths,
      Future<void> Function(DisplayRender render) verify,
    ) async {
      for (final width in widths) {
        await withDisplayCase(DisplayCase(fixture(name), DisplayViewer.native, width), verify);
      }
    }

    test('auto_scale_reflow_table reflows, shrinks text and caps padding at <= 480', () async {
      await onNative('auto_scale_reflow_table', [296, 336, 390], (render) async {
        expect(autoScalePathOf(render.frame), AutoScalePath.reflow);
        final changes = reflowChangesOf(render.frame);
        expect(changes.shrunkText, greaterThan(0), reason: render.displayCase.label);
        expect(changes.cappedPadding, greaterThan(0), reason: render.displayCase.label);
      });
    });

    test('auto_scale_zoom takes the zoom path at every native width', () async {
      await onNative('auto_scale_zoom', DisplayViewer.native.widths, (render) async {
        expect(autoScalePathOf(render.frame), AutoScalePath.zoom,
            reason: render.displayCase.label);
      });
    });

    test('quote_toggle_wide marks the expanded quote responsive at <= 480', () async {
      await onNative('quote_toggle_wide', [296, 336, 390], (render) async {
        await render.frame.toggleQuote();
        expect(render.frame.query('blockquote.tmail-responsive-quote'), isNotNull,
            reason: render.displayCase.label);
      });
    });

    test('lazy_images keeps its background unloaded until scrolled to', () async {
      await onNative('lazy_images', [390], (render) async {
        final lazy = render.frame.queryAll('.tmail-content [lazy]');
        expect(lazy, isNotEmpty);
      });
    });
  });

  group('checkers catch what they exist for', () {
    Future<List<String>> check(
      ExpectChecker checker,
      String html, {
      DisplayMutation? mutation,
    }) async {
      final render = await renderDisplayCase(
        DisplayCase(
          HtmlEmailCorpusFixture(name: 'probe', category: 'checkers', html: html),
          DisplayViewer.native,
          390,
        ),
        mutation: mutation,
      );
      try {
        return [for (final v in await checker(render)) '${v.rule} ${v.path} ${v.detail}'];
      } finally {
        render.dispose();
      }
    }

    DisplayMutation onLoad(String script) => DisplayMutation(
          document: (document) => document.replaceFirst(
            '</body>',
            "<script>window.addEventListener('load', function() {"
                "var p = document.querySelector('.tmail-content p'); $script });</script></body>",
          ),
        );

    test('noScale accepts an email that fits untouched', () async {
      expect(await check(noScaleChecker, '<p>fits</p>'), isEmpty);
    });

    test('noScale catches an inline style a viewer script rewrote', () async {
      expect(
        await check(noScaleChecker, '<p>fits</p>', mutation: onLoad("p.style.fontSize = '9px';")),
        ['noScale .tmail-content > p changed: style="font-size: 9px;"'],
      );
    });

    test('noScale catches a zoom applied by a stylesheet', () async {
      expect(
        await check(
          noScaleChecker,
          '<p>fits</p>',
          mutation: DisplayMutation(
            document: (document) => document.replaceFirst(
              '</head>',
              '<style>.tmail-content p { zoom: 0.5; }</style></head>',
            ),
          ),
        ),
        ['noScale .tmail-content > p changed: style="null"'],
      );
    });

    test('noQuoteToggle catches a toggle added to a reachable quote', () async {
      final violations = await check(noQuoteToggleChecker, '<blockquote><p>q</p></blockquote>');
      expect(violations, ['noQuoteToggle .tmail-content > div > button toggle added']);
    });

    test('noQuoteToggle catches a fixture without a blockquote', () async {
      expect(await check(noQuoteToggleChecker, '<p>x</p>'), [
        'noQuoteToggle .tmail-content fixture has no blockquote',
      ]);
    });

    test('fullDisplay catches a body taller than the viewer cap', () async {
      final cap = ConstantsUI.htmlContentMaxHeight.toInt();
      expect(await check(fullDisplayChecker, '<div style="height:${cap}px">tall</div>'), [
        'fullDisplay .tmail-content body height ${cap}px',
      ]);
    });
  });

  for (final displayCase in displayCases()) {
    for (final label in displayCase.fixture.expect) {
      if (!expectApplies(label, displayCase.viewer)) continue;
      test('${displayCase.label} expect ${label.name}', () async {
        await withDisplayCase(displayCase, (render) async {
          final violations = await expectCheckers[label]!(render);
          expect(
            violations.map((v) => v.describe(displayCase)).toList(),
            isEmpty,
          );
        });
      });
    }
  }
}
