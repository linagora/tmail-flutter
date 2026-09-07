@TestOn('chrome')

import 'dart:async';
import 'dart:js_interop';

import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/html/mobile_email_responsive_layout_script.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

import 'mobile_email_responsive_layout_browser_test.dart'
    show EmailFixture, EmailViewport, withEmail;

bool hasClass(EmailViewport viewport, String selector, String className) =>
    viewport.element(selector).classList.contains(className);

String? inlineStyleOf(EmailViewport viewport, String selector) =>
    viewport.element(selector).getAttribute('style');

/// Widens the rendered viewport the way a rotation does, then waits for the
/// resize listener to run its layout pass.
Future<void> rotateTo(EmailViewport viewport, int width) async {
  final view = viewport.element('body').ownerDocument!.defaultView!;
  (view.frameElement as web.HTMLIFrameElement).width = '$width';
  await Future<void>.delayed(const Duration(milliseconds: 200));
}

/// The quote-toggle document needs its own stylesheet and script alongside the
/// reflow script, which the shared fixture does not carry, so this builds the
/// document the Email View assembles when enableQuoteToggle is on.
class QuoteToggleViewport {

  final web.HTMLIFrameElement _frame;

  const QuoteToggleViewport._(this._frame);

  static Future<QuoteToggleViewport> render(String html) async {
    final frame = web.HTMLIFrameElement()
      ..width = '360'
      ..height = '480'
      ..srcdoc = HtmlUtils.generateHtmlDocument(
        content: HtmlUtils.addQuoteToggle(html),
        styleCSS: HtmlUtils.quoteToggleStyle,
        javaScripts: HtmlUtils.quoteToggleScript +
            MobileEmailResponsiveLayoutScript.generate(
              contentSizeChangedEventJSChannelName: 'TestContentSizeChanged',
            ),
      ).toJS;

    final loaded = Completer<void>();
    frame.addEventListener('load', (web.Event _) {
      if (!loaded.isCompleted) loaded.complete();
    }.toJS);
    web.document.body!.append(frame);
    await loaded.future;
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return QuoteToggleViewport._(frame);
  }

  web.Element get _content =>
      _frame.contentDocument!.getElementsByClassName('tmail-content').item(0)!;

  bool get overflowsHorizontally =>
      _content.scrollWidth > _content.clientWidth + 1;

  bool get isQuoteVisible =>
      _frame.contentDocument!.querySelector('blockquote')!.clientWidth > 0;

  double widthOf(String selector) => _frame.contentDocument!
      .querySelector(selector)!
      .getBoundingClientRect()
      .width
      .toDouble();

  double get contentWidth => _content.clientWidth.toDouble();

  Future<void> expandQuote() async {
    (_frame.contentDocument!.querySelector('.quote-toggle-button')!
        as web.HTMLElement).click();
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  void dispose() => _frame.remove();
}

void main() {
  group('Mobile email responsive layout side effects', () {
    verifyQuotedBodyTypography();
    verifyNoWrapRelaxationScope();
    verifySenderStylesAreRestored();
    verifyQuoteToggleReflow();
  });
}

/// A collapsed quote is display:none, so it has no width and the first pass
/// cannot see anything inside it. Expanding it reveals content that was never
/// measured, which is why the script listens for the toggle. Without that
/// listener the email overflows sideways the moment the quote opens.
void verifyQuoteToggleReflow() {
  test('reflows wide content revealed by expanding a trimmed quote', () async {
    final viewport = await QuoteToggleViewport.render(
      '<p>Latest reply</p>'
      '<blockquote>'
        '<div id="wide" style="width:790px">Wide quoted newsletter</div>'
      '</blockquote>',
    );

    try {
      expect(viewport.isQuoteVisible, isFalse, reason: 'starts collapsed');
      expect(viewport.overflowsHorizontally, isFalse);

      await viewport.expandQuote();

      expect(viewport.isQuoteVisible, isTrue);
      expect(
        viewport.overflowsHorizontally,
        isFalse,
        reason: 'the toggle listener must re-run the layout pass',
      );
      expect(viewport.widthOf('#wide'), lessThanOrEqualTo(viewport.contentWidth));
    } finally {
      viewport.dispose();
    }
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

        await rotateTo(viewport, 900);

        expect(
          viewport.widthOf('#wide'),
          790,
          reason: 'the reflow must be undone once the width fits again',
        );
        expect(
          inlineStyleOf(viewport, '#wide'),
          'width: 790px;',
          reason: 'no leftover width/max-width !important from the reflow',
        );
      },
    );
  });
}

/// A quote holding an overflow root is marked and drops to 13px below 480px.
/// The rule targets the blockquote itself, so it moves the inherited size only
/// and quoted text that declares its own size keeps it.
void verifyQuotedBodyTypography() {
  test('shrinks inherited quoted text but keeps a size declared by the sender',
      () async {
    await withEmail(
      const EmailFixture(
        '<blockquote>'
          '<p id="inherited-text">Quoted reply without its own font size</p>'
          '<p id="declared-text" style="font-size:16px">Quoted reply at 16px</p>'
          '<div id="wide" style="width:790px">Wide quoted newsletter</div>'
        '</blockquote>',
      ),
      (viewport) async {
        expect(
          hasClass(viewport, 'blockquote', 'tmail-responsive-quote'),
          isTrue,
        );
        expect(viewport.renderedFontSizeOf('#inherited-text'), 13);
        expect(
          viewport.renderedFontSizeOf('#declared-text'),
          16,
          reason: 'the rule targets the blockquote, so an explicit size from '
              'the sender must survive',
        );
      },
    );
  });

  test('leaves quoted typography alone when nothing in the quote overflows',
      () async {
    await withEmail(
      const EmailFixture(
        '<blockquote>'
          '<p id="inherited-text">Quoted reply without its own font size</p>'
        '</blockquote>',
      ),
      (viewport) async {
        expect(
          hasClass(viewport, 'blockquote', 'tmail-responsive-quote'),
          isFalse,
        );
        expect(viewport.renderedFontSizeOf('#inherited-text'), greaterThan(13));
      },
    );
  });
}

/// relaxNoWrapContent() rewrites white-space only where an element's own
/// content overflows it, so a single-line layout that already fits is
/// untouched. overflowsOwnBox() measures that through two different branches:
/// a block reports its own scroll width, while an inline box reports none and
/// falls back to comparing its rendered width against the email width. A row
/// that fits must be left alone on both.
void verifyNoWrapRelaxationScope() {
  test('keeps nowrap on a fitting row and on the inline links inside it',
      () async {
    await withEmail(
      const EmailFixture(
        '<div id="button-row" style="white-space:nowrap">'
          '<a id="button" href="https://example.com">Open</a> '
          '<a href="https://example.com">Reply</a>'
        '</div>',
      ),
      (viewport) async {
        // Block: clientWidth is non-zero, so scrollWidth decides.
        expect(viewport.whiteSpaceOf('#button-row'), 'nowrap');
        // Inline: clientWidth and scrollWidth are both zero, so the rendered
        // width against the email width decides.
        expect(viewport.whiteSpaceOf('#button'), 'nowrap');
      },
    );
  });
}
