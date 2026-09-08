@TestOn('chrome')

import 'package:flutter_test/flutter_test.dart';

import 'mobile_email_responsive_layout_fixture.dart';

String buildLargeEmail(int rows) {
  final buffer = StringBuffer('<div id="wide" style="width:790px">');
  for (var row = 0; row < rows; row++) {
    buffer.write(
      '<div class="row"><span>Row $row</span><span>column b</span>'
      '<span>column c</span><b id="cell$row">value</b></div>',
    );
  }
  buffer.write('</div>');
  return buffer.toString();
}

void main() {
  group('Mobile email responsive layout side effects', () {
    verifyQuotedBodyTypography();
    verifyNoWrapRelaxationScope();
    verifySenderStylesAreRestored();
    verifyQuoteToggleReflow();
    verifyLargeEmailStaysLinear();
  });
}

/// The pass walks every element, so its cost has to stay proportional to the
/// document rather than to the square of it. An absolute budget cannot show
/// that — it only says the machine was fast enough — so this compares two
/// documents instead: quadrupling the element count must not cost far more
/// than four times the work.
///
/// Measured locally the ratio sits at 3.0-3.1 across runs, because a fixed
/// per-pass overhead is amortised over the larger document. A quadratic scan
/// puts it near 16, so the allowance below is wide enough never to flake and
/// still far below what a regression would produce.
void verifyLargeEmailStaysLinear() {
  const smallRows = 1000;
  const largeRows = smallRows * 4;
  const maxGrowthFactor = 8;

  test('reflows four times the elements in far less than four times the '
      'squared work', () async {
    final small = await _settleLargeEmail(smallRows);
    final large = await _settleLargeEmail(largeRows);

    expect(
      large / small,
      lessThan(maxGrowthFactor),
      reason: '${smallRows * 5} elements took ${small}ms and '
          '${largeRows * 5} took ${large}ms, a factor of '
          '${(large / small).toStringAsFixed(2)} for 4x the document, which '
          'points at a scan that no longer grows linearly',
    );
  }, timeout: const Timeout(Duration(minutes: 2)));
}

/// Renders an email of [rows] rows, asserts it was actually reflowed, and
/// returns how long the pass took.
Future<double> _settleLargeEmail(int rows) async {
  final viewport = await EmailViewport.renderAndSettle(
    EmailFixture(buildLargeEmail(rows)),
  );

  try {
    expect(
      viewport.overflowsHorizontally,
      isFalse,
      reason: 'a $rows row email must still be reflowed, not given up on',
    );
    expect(viewport.renderedFontSizeOf('#cell0'), 16);

    return viewport.settleMilliseconds!;
  } finally {
    viewport.dispose();
  }
}

/// A collapsed quote is display:none, so it has no width and the first pass
/// cannot see anything inside it. Expanding it reveals content that was never
/// measured, which is why the script listens for the toggle. Without that
/// listener the email overflows sideways the moment the quote opens.
void verifyQuoteToggleReflow() {
  test('reflows wide content revealed by expanding a trimmed quote', () async {
    await withEmail(
      const EmailFixture(
        '<p>Latest reply</p>'
        '<blockquote>'
          '<div id="wide" style="width:790px">Wide quoted newsletter</div>'
        '</blockquote>',
        quoteToggle: true,
      ),
      (viewport) async {
        expect(viewport.isQuoteVisible, isFalse, reason: 'starts collapsed');
        expect(viewport.overflowsHorizontally, isFalse);

        await viewport.expandQuote();

        expect(viewport.isQuoteVisible, isTrue);
        expect(
          viewport.overflowsHorizontally,
          isFalse,
          reason: 'the toggle listener must re-run the layout pass',
        );
        expect(
          viewport.widthOf('#wide'),
          lessThanOrEqualTo(viewport.contentWidth),
        );
      },
    );
  });
}

/// Every pass starts by undoing the previous one. If that restore drops or
/// keeps the wrong value, an email stays stuck at the narrow layout after the
/// phone is rotated back to a width that no longer needs it.
void verifySenderStylesAreRestored() {
  test('restores the sender width when the viewport no longer overflows',
      () async {
    await withEmail(
      const EmailFixture(
        '<div id="wide" style="width:790px">Wide newsletter</div>',
      ),
      (viewport) async {
        expect(viewport.widthOf('#wide'), viewport.contentWidth);

        await viewport.resizeTo(900);

        expect(
          viewport.widthOf('#wide'),
          790,
          reason: 'the reflow must be undone once the width fits again',
        );
        final width = viewport.inlinePropertyOf('#wide', 'width');
        expect(width.value, '790px', reason: 'the sender width is restored');
        expect(
          width.priority,
          isEmpty,
          reason: 'no leftover !important from the reflow',
        );
        expect(
          viewport.inlinePropertyOf('#wide', 'max-width').value,
          isEmpty,
          reason: 'the max-width the reflow added is removed again',
        );
      },
    );
  });
}

/// A quote holding an overflow root is marked and drops to 13px below 480px.
/// The rule targets the blockquote itself, so it moves the inherited size only
/// and quoted text that declares its own size keeps it.
void verifyQuotedBodyTypography() {
  testQuotedTypography(
    'shrinks inherited quoted text but keeps a size declared by the sender',
    const EmailFixture(
      '<blockquote>'
        '<p id="inherited-text">Quoted reply without its own font size</p>'
        '<p id="declared-text" style="font-size:16px">Quoted reply at 16px</p>'
        '<div id="wide" style="width:790px">Wide quoted newsletter</div>'
      '</blockquote>',
    ),
    const [
      ElementLayout('#inherited-text', fontSize: 13),
      // The rule targets the blockquote, so an explicit size from the sender
      // must survive.
      ElementLayout('#declared-text', fontSize: 16),
    ],
    marksResponsiveQuote: true,
  );

  testQuotedTypography(
    'leaves quoted typography alone when nothing in the quote overflows',
    const EmailFixture(
      '<blockquote>'
        '<p id="inherited-text">Quoted reply without its own font size</p>'
      '</blockquote>',
    ),
    [ElementLayout('#inherited-text', fontSize: greaterThan(13))],
    marksResponsiveQuote: false,
  );
}

/// Both quote cases share one arrangement and differ only by whether the quote
/// is marked and by the size the quoted text ends up with.
void testQuotedTypography(
  String description,
  EmailFixture fixture,
  List<ElementLayout> expectations, {
  required bool marksResponsiveQuote,
}) {
  test(description, () async {
    await withEmail(fixture, (viewport) async {
      expect(
        viewport.hasClass('blockquote', 'tmail-responsive-quote'),
        marksResponsiveQuote,
        reason: 'the quote is marked only when it holds an overflow root',
      );
      for (final expectation in expectations) {
        expectation.verifyAgainst(viewport);
      }
    });
  });
}

/// relaxNoWrapContent() rewrites white-space only where an element's own
/// content overflows it, so a single-line layout that already fits is
/// untouched. overflowsOwnBox() measures that through two different branches:
/// a block reports its own scroll width, while an inline box reports none and
/// falls back to comparing its rendered width against the email width. A row
/// that fits must be left alone on both.
void verifyNoWrapRelaxationScope() {
  testEmailLayout(
    'keeps nowrap on a fitting row and on the inline links inside it',
    const EmailFixture(
      '<div id="button-row" style="white-space:nowrap">'
        '<a id="button" href="https://example.com">Open</a> '
        '<a href="https://example.com">Reply</a>'
      '</div>',
    ),
    const [
      // Block: clientWidth is non-zero, so scrollWidth decides.
      ElementLayout('#button-row', whiteSpace: 'nowrap'),
      // Inline: clientWidth and scrollWidth are both zero, so the rendered
      // width against the email width decides.
      ElementLayout('#button', whiteSpace: 'nowrap'),
    ],
  );
}
