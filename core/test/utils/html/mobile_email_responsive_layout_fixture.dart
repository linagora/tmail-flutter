import 'dart:async';
import 'dart:js_interop';

import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/html/mobile_email_responsive_layout_script.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

const contentSizeChangedEventJSChannelName = 'MobileEmailContentSizeChanged';
const defaultViewportWidth = 360;

typedef EmailViewportVerification = Future<void> Function(EmailViewport viewport);

/// The email under test together with the viewport it is rendered in.
class EmailFixture {

  final String html;
  final TextDirection? direction;
  final int viewportWidth;

  /// Wraps a trimmed quote in the toggle the Email View adds when
  /// `enableQuoteToggle` is on, along with the stylesheet and script driving
  /// it, so the collapsed state matches what the app ships.
  final bool quoteToggle;

  const EmailFixture(
    this.html, {
    this.direction,
    this.viewportWidth = defaultViewportWidth,
    this.quoteToggle = false,
  });

  String get _content => quoteToggle ? HtmlUtils.addQuoteToggle(html) : html;

  String? get _styleCSS => quoteToggle ? HtmlUtils.quoteToggleStyle : null;

  String get _javaScripts =>
      (quoteToggle ? HtmlUtils.quoteToggleScript : '') +
      MobileEmailResponsiveLayoutScript.generate(
        contentSizeChangedEventJSChannelName:
            contentSizeChangedEventJSChannelName,
      );

  String buildDocument() => HtmlUtils.generateHtmlDocument(
        content: _content,
        direction: direction,
        styleCSS: _styleCSS,
        javaScripts: _javaScripts,
      );
}

/// Renders the email document exactly as the native Email View builds it, so
/// the assertions measure the shipped layout policy and not a copy of it.
class EmailViewport {

  final web.HTMLIFrameElement _frame;

  const EmailViewport._(this._frame);

  static Future<EmailViewport> render(EmailFixture fixture) async {
    final frame = web.HTMLIFrameElement()
      ..width = '${fixture.viewportWidth}'
      ..height = '480'
      ..srcdoc = fixture.buildDocument().toJS;

    final loaded = Completer<void>();
    frame.addEventListener('load', (web.Event _) {
      if (!loaded.isCompleted) loaded.complete();
    }.toJS);
    web.document.body!.append(frame);
    await loaded.future;
    // The layout pass is scheduled on an animation frame after load.
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return EmailViewport._(frame);
  }

  web.Element get _content =>
      _frame.contentDocument!.getElementsByClassName('tmail-content').item(0)!;

  web.Element element(String selector) =>
      _frame.contentDocument!.querySelector(selector)!;

  bool get overflowsHorizontally =>
      _content.scrollWidth > _content.clientWidth + 1;

  /// Width the email body can occupy, which is narrower than the viewport
  /// because the document keeps its own margin.
  double get contentWidth => _content.clientWidth.toDouble();

  double widthOf(String selector) =>
      element(selector).getBoundingClientRect().width.toDouble();

  /// Font size as rendered, which is the declared size shrunk by every zoom
  /// factor applied to the element and its ancestors.
  double renderedFontSizeOf(String selector) {
    final target = element(selector);
    final style = _frame.contentWindow!.getComputedStyle(target);
    var scale = 1.0;
    web.Element? current = target;
    while (current != null) {
      final zoom = double.tryParse(
        _frame.contentWindow!.getComputedStyle(current).zoom,
      );
      scale *= zoom ?? 1.0;
      current = current.parentElement;
    }
    return (double.tryParse(style.fontSize.replaceAll('px', '')) ?? 0) * scale;
  }

  String whiteSpaceOf(String selector) =>
      _frame.contentWindow!.getComputedStyle(element(selector)).whiteSpace;

  double aspectRatioOf(String selector) {
    final rect = element(selector).getBoundingClientRect();
    return rect.width / rect.height;
  }

  bool hasClass(String selector, String className) =>
      element(selector).classList.contains(className);

  /// Inline value the sender declared for [property], and whether the reflow
  /// left its `!important` priority behind.
  ({String value, String priority}) inlinePropertyOf(
    String selector,
    String property,
  ) {
    final style = (element(selector) as web.HTMLElement).style;
    return (
      value: style.getPropertyValue(property),
      priority: style.getPropertyPriority(property),
    );
  }

  bool get isQuoteVisible => element('blockquote').clientWidth > 0;

  Future<void> expandQuote() async {
    (element('.quote-toggle-button') as web.HTMLElement).click();
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  /// Widens the rendered viewport the way a rotation does, then waits for the
  /// resize listener to run its layout pass.
  Future<void> resizeTo(int width) async {
    _frame.width = '$width';
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  void dispose() => _frame.remove();
}

Future<void> withEmail(
  EmailFixture fixture,
  EmailViewportVerification verify,
) async {
  final viewport = await EmailViewport.render(fixture);
  try {
    await verify(viewport);
  } finally {
    viewport.dispose();
  }
}

/// Width an element must end up with, relative to what the email body can
/// occupy. Both cases are resolved at assertion time because the body width
/// depends on the document margin.
enum ElementWidth {
  /// Reflowed to exactly the width the email body can occupy.
  fillsContent,

  /// Reflowed to no more than the width the email body can occupy.
  fitsContent,
}

/// What the layout pass must leave behind for one element. Every field takes a
/// plain value or a matcher, and an omitted field is simply not asserted.
class ElementLayout {

  final String selector;
  final ElementWidth? width;
  final Object? fontSize;
  final Object? whiteSpace;

  const ElementLayout(
    this.selector, {
    this.width,
    this.fontSize,
    this.whiteSpace,
  });

  void verifyAgainst(EmailViewport viewport) {
    switch (width) {
      case ElementWidth.fillsContent:
        expect(viewport.widthOf(selector), viewport.contentWidth,
            reason: '$selector must fill the email body');
      case ElementWidth.fitsContent:
        expect(viewport.widthOf(selector),
            lessThanOrEqualTo(viewport.contentWidth),
            reason: '$selector must not be wider than the email body');
      case null:
        break;
    }
    if (fontSize != null) {
      expect(viewport.renderedFontSizeOf(selector), fontSize,
          reason: 'rendered font size of $selector');
    }
    if (whiteSpace != null) {
      expect(viewport.whiteSpaceOf(selector), whiteSpace,
          reason: 'white-space of $selector');
    }
  }
}

/// Registers a test that renders [fixture], checks the email against
/// [overflowsHorizontally], then applies every entry in [expectations].
///
/// Nearly every case in these suites is that same arrangement varying only by
/// the document and the expected per-element result, so they are declared as
/// data instead of repeating the body.
void testEmailLayout(
  String description,
  EmailFixture fixture,
  List<ElementLayout> expectations, {
  bool overflowsHorizontally = false,
}) {
  test(description, () async {
    await withEmail(fixture, (viewport) async {
      expect(
        viewport.overflowsHorizontally,
        overflowsHorizontally,
        reason: 'the email must not scroll sideways',
      );
      for (final expectation in expectations) {
        expectation.verifyAgainst(viewport);
      }
    });
  });
}
