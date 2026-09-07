@TestOn('chrome')

import 'dart:async';
import 'dart:js_interop';

import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/html/mobile_email_responsive_layout_script.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

const _contentSizeChangedEventJSChannelName = 'MobileEmailContentSizeChanged';
const _viewportWidth = 360;
const _readableFontSize = 12;

/// Renders the email document exactly as the native Email View builds it, so
/// the assertions below measure the shipped layout policy and not a copy of it.
class EmailViewport {

  final web.HTMLIFrameElement _frame;

  const EmailViewport._(this._frame);

  static Future<EmailViewport> render(
    String content, {
    TextDirection? direction,
  }) async {
    final frame = web.HTMLIFrameElement()
      ..width = '$_viewportWidth'
      ..height = '480'
      ..srcdoc = HtmlUtils.generateHtmlDocument(
        content: content,
        direction: direction,
        javaScripts: MobileEmailResponsiveLayoutScript.generate(
          contentSizeChangedEventJSChannelName:
              _contentSizeChangedEventJSChannelName,
        ),
      ).toJS;

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

  void dispose() => _frame.remove();
}

Future<void> withEmail(
  String content,
  Future<void> Function(EmailViewport viewport) verify, {
  TextDirection? direction,
}) async {
  final viewport = await EmailViewport.render(content, direction: direction);
  try {
    await verify(viewport);
  } finally {
    viewport.dispose();
  }
}

void main() {
  group('Mobile email responsive layout', () {
    verifyLayoutsThatNeedNoChange();
    verifyFixedWidthWrapperReflow();
    verifyNonWrappingContentReflow();
    verifyScalingFallback();
  });
}

void verifyLayoutsThatNeedNoChange() {
  test('keeps a plain email untouched', () async {
    await withEmail(
      '<p id="body" style="font-size:16px">A plain paragraph.</p>',
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.renderedFontSizeOf('#body'), 16);
      },
    );
  });

  test('keeps a responsive table untouched', () async {
    await withEmail(
      '<table style="width:100%"><tr>'
      '<td id="cell" style="font-size:16px">Cell A</td>'
      '<td style="font-size:16px">Cell B</td>'
      '</tr></table>',
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.renderedFontSizeOf('#cell'), 16);
      },
    );
  });
}

void verifyFixedWidthWrapperReflow() {
  test('reflows a fixed-width wrapper instead of shrinking its text', () async {
    await withEmail(
      '<div id="wrapper" style="width:790px">'
      '<p id="body" style="font-size:16px">Newsletter paragraph.</p>'
      '</div>',
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.widthOf('#wrapper'), viewport.contentWidth);
        expect(viewport.renderedFontSizeOf('#body'), 16);
      },
    );
  });

  test('reflows a fixed-width wrapper in a right-to-left email', () async {
    await withEmail(
      '<div id="wrapper" style="width:790px">'
      '<p id="body" style="font-size:16px">Right to left body.</p>'
      '</div>',
      direction: TextDirection.rtl,
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.widthOf('#wrapper'), viewport.contentWidth);
        expect(viewport.renderedFontSizeOf('#body'), 16);
      },
    );
  });

  test('reflows a wrapper whose ancestor clips the overflow', () async {
    await withEmail(
      '<div style="overflow:hidden;width:100%">'
      '<div id="wrapper" style="width:900px;font-size:16px">Clipped body</div>'
      '</div>',
      (viewport) async {
        expect(viewport.widthOf('#wrapper'), viewport.contentWidth);
        expect(viewport.renderedFontSizeOf('#wrapper'), 16);
      },
    );
  });
}

void verifyNonWrappingContentReflow() {
  test('wraps non-wrapping content that overflows the viewport', () async {
    await withEmail(
      '<div id="row" style="white-space:nowrap;font-size:16px">'
      '${'word ' * 120}'
      '</div>',
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.widthOf('#row'), lessThanOrEqualTo(viewport.contentWidth));
        expect(viewport.renderedFontSizeOf('#row'), 16);
      },
    );
  });

  test('keeps the spacing of preformatted content while wrapping it', () async {
    await withEmail(
      '<pre id="listing" style="white-space:pre;font-size:16px">'
      'col1    col2    col3    ${'x' * 160}'
      '</pre>',
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.whiteSpaceOf('#listing'), 'pre-wrap');
        expect(viewport.renderedFontSizeOf('#listing'), 16);
      },
    );
  });
}

void verifyScalingFallback() {
  test('scales an oversized image without distorting it', () async {
    await withEmail(
      '<img id="banner" width="800" height="400" '
      'style="width:800px;height:400px" '
      'src="data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==">',
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.aspectRatioOf('#banner'), closeTo(2, 0.05));
      },
    );
  });

  test('breaks unbreakable cell text instead of shrinking it', () async {
    await withEmail(
      '<table><tr>'
      '<td id="cell" style="font-size:16px">${'A' * 120}</td>'
      '</tr></table>',
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.renderedFontSizeOf('#cell'), 16);
      },
    );
  });

  test('reflows a fixed-width table before shrinking its text', () async {
    await withEmail(
      '<table id="grid" width="900" style="width:900px"><tr>'
      '<td id="cell" width="450" style="width:450px;padding:24px;font-size:16px">Column one</td>'
      '<td width="450" style="width:450px;padding:24px;font-size:16px">Column two</td>'
      '</tr></table>',
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.widthOf('#grid'), lessThanOrEqualTo(viewport.contentWidth));
        expect(
          viewport.renderedFontSizeOf('#cell'),
          greaterThanOrEqualTo(_readableFontSize),
        );
      },
    );
  });
}
