@TestOn('chrome')
@Tags(['display'])
library;

import 'package:flutter_test/flutter_test.dart';

import 'display_harness/display_case.dart';

/// Every corpus fixture through the production pipeline on every viewer and
/// email pane width: it renders offline, keeps its text, and a trimmed quote
/// starts collapsed and expands on tap. The native viewer (responsive script)
/// must not overflow; per-viewer layout rules live in the display rule suites.
void main() {
  for (final displayCase in displayCases()) {
    test(displayCase.label, () async {
      await withDisplayCase(displayCase, (render) async {
        final frame = render.frame;
        if (!displayCase.fixture.allowEmptyBody) {
          expect(
            frame.content.textContent?.trim(),
            isNotEmpty,
            reason: displayCase.failure('keeps text', '.tmail-content'),
          );
        }
        if (displayCase.viewer.hasQuoteToggle &&
            (displayCase.fixture.expectQuote ||
                render.transformedHtml.contains('<blockquote'))) {
          expect(frame.hasQuoteToggle, isTrue,
              reason: displayCase.failure('quote toggle', '.quote-toggle-button', 'missing'));
          expect(frame.isQuoteExpanded, isFalse,
              reason: displayCase.failure('quote toggle', 'blockquote', 'not collapsed'));
          await frame.toggleQuote();
          expect(frame.isQuoteExpanded, isTrue,
              reason: displayCase.failure('quote toggle', 'blockquote', 'does not expand'));
        }
        if (displayCase.viewer == DisplayViewer.native) {
          final overflows = frame.overflows();
          expect(overflows, isEmpty,
              reason: displayCase.failure(
                'no horizontal overflow',
                overflows.isEmpty ? '' : overflows.first.path,
                overflows.map((o) => '+${o.pixels.toStringAsFixed(1)}px').join(', '),
              ));
        }
      });
    });
  }
}
