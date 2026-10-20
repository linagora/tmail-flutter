@TestOn('chrome')
@Tags(['display'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/html_emails/html_email_corpus_fixture.dart';
import 'display_harness/display_case.dart';

/// Every corpus fixture through the production pipeline on every viewer and
/// email pane width: it renders offline, keeps its text, and a trimmed quote
/// starts collapsed and expands on tap. The native viewer (responsive script)
/// must not overflow; per-viewer layout rules live in the display rule suites.
void main() {
  for (final displayCase in displayCases()) {
    test(displayCase.label, () async {
      await withDisplayCase(displayCase, (render) async {
        _expectKeepsText(render);
        if (_hasQuoteToggle(render)) await _expectQuoteToggle(render);
        if (displayCase.viewer == DisplayViewer.native) _expectNoOverflow(render);
      });
    });
  }
}

bool _hasQuote(DisplayRender render) {
  final fixture = render.displayCase.fixture;
  if (fixture.expectQuote) return true;
  // A blockquote deeper than two div levels gets no toggle (D3); the
  // noQuoteToggle checker covers that case.
  final quoteReachable = !fixture.expect.contains(HtmlEmailExpect.noQuoteToggle);
  return quoteReachable && render.transformedHtml.contains('<blockquote');
}

bool _hasQuoteToggle(DisplayRender render) =>
    render.displayCase.viewer.hasQuoteToggle && _hasQuote(render);

void _expectKeepsText(DisplayRender render) {
  final displayCase = render.displayCase;
  if (displayCase.fixture.allowEmptyBody) return;
  expect(
    render.frame.content.textContent?.trim(),
    isNotEmpty,
    reason: displayCase.failure('keeps text', '.tmail-content'),
  );
}

Future<void> _expectQuoteToggle(DisplayRender render) async {
  final displayCase = render.displayCase;
  final frame = render.frame;
  expect(frame.hasQuoteToggle, isTrue,
      reason: displayCase.failure('quote toggle', '.quote-toggle-button', 'missing'));
  expect(frame.isQuoteExpanded, isFalse,
      reason: displayCase.failure('quote toggle', 'blockquote', 'not collapsed'));
  await frame.toggleQuote();
  expect(frame.isQuoteExpanded, isTrue,
      reason: displayCase.failure('quote toggle', 'blockquote', 'does not expand'));
}

void _expectNoOverflow(DisplayRender render) {
  final overflows = render.frame.overflows();
  expect(overflows, isEmpty,
      reason: render.displayCase.failure(
        'no horizontal overflow',
        overflows.isEmpty ? '' : overflows.first.path,
        overflows.map((o) => '+${o.pixels.toStringAsFixed(1)}px').join(', '),
      ));
}
