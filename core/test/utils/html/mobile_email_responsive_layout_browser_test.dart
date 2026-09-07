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

typedef EmailViewportVerification = Future<void> Function(EmailViewport viewport);

/// The email under test together with the viewport it is rendered in.
class EmailFixture {

  final String html;
  final TextDirection? direction;
  final int viewportWidth;

  const EmailFixture(
    this.html, {
    this.direction,
    this.viewportWidth = _viewportWidth,
  });
}

/// Renders the email document exactly as the native Email View builds it, so
/// the assertions below measure the shipped layout policy and not a copy of it.
class EmailViewport {

  final web.HTMLIFrameElement _frame;

  const EmailViewport._(this._frame);

  static Future<EmailViewport> render(EmailFixture fixture) async {
    final frame = web.HTMLIFrameElement()
      ..width = '${fixture.viewportWidth}'
      ..height = '480'
      ..srcdoc = HtmlUtils.generateHtmlDocument(
        content: fixture.html,
        direction: fixture.direction,
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

void main() {
  group('Mobile email responsive layout', () {
    verifyLayoutsThatNeedNoChange();
    verifyFixedWidthWrapperReflow();
    verifyNonWrappingContentReflow();
    verifyScalingFallback();
    verifyTableWidthsOutsideTheMobileBreakpoint();
    verifyDefensiveLayoutGuards();
  });
}

void verifyLayoutsThatNeedNoChange() {
  test('keeps a plain email untouched', () async {
    await withEmail(
      const EmailFixture(
        '<p id="body" style="font-size:16px">A plain paragraph.</p>',
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.renderedFontSizeOf('#body'), 16);
      },
    );
  });

  test('keeps a responsive table untouched', () async {
    await withEmail(
      const EmailFixture(
        '<table style="width:100%"><tr>'
        '<td id="cell" style="font-size:16px">Cell A</td>'
        '<td style="font-size:16px">Cell B</td>'
        '</tr></table>',
      ),
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
      const EmailFixture(
        '<div id="wrapper" style="width:790px">'
        '<p id="body" style="font-size:16px">Newsletter paragraph.</p>'
        '</div>',
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.widthOf('#wrapper'), viewport.contentWidth);
        expect(viewport.renderedFontSizeOf('#body'), 16);
      },
    );
  });

  test('reflows a fixed-width wrapper in a right-to-left email', () async {
    await withEmail(
      const EmailFixture(
        '<div id="wrapper" style="width:790px">'
        '<p id="body" style="font-size:16px">Right to left body.</p>'
        '</div>',
        direction: TextDirection.rtl,
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.widthOf('#wrapper'), viewport.contentWidth);
        expect(viewport.renderedFontSizeOf('#body'), 16);
      },
    );
  });

  test('reflows a wrapper whose ancestor clips the overflow', () async {
    await withEmail(
      const EmailFixture(
        '<div style="overflow:hidden;width:100%">'
        '<div id="wrapper" style="width:900px;font-size:16px">Clipped body</div>'
        '</div>',
      ),
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
      EmailFixture(
        '<div id="row" style="white-space:nowrap;font-size:16px">'
        '${'word ' * 120}'
        '</div>',
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.widthOf('#row'), lessThanOrEqualTo(viewport.contentWidth));
        expect(viewport.renderedFontSizeOf('#row'), 16);
      },
    );
  });

  test('wraps a non-wrapping table cell instead of scaling the table', () async {
    await withEmail(
      EmailFixture(
        '<table><tr>'
        '<td id="cell" style="white-space:nowrap;font-size:16px">'
        '${'word ' * 40}'
        '</td>'
        '</tr></table>',
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.whiteSpaceOf('#cell'), 'normal');
        expect(viewport.renderedFontSizeOf('#cell'), 16);
      },
    );
  });

  test('wraps a link that forbids wrapping instead of shrinking it', () async {
    await withEmail(
      const EmailFixture(
        '<div id="body" style="font-size:16px">Forwarded message</div>'
        '<a id="link" href="https://example.com/pull/12" rel="noreferrer" '
        'style="white-space:nowrap;word-break:keep-all;font-size:16px">'
        'example.com/acme/widgets/pull/12/changes/0123456789abcdef0123456789'
        'abcdef01234567#diff-fedcba9876543210fedcba9876543210fedcba9876543210'
        'fedcba9876543210L42'
        '</a>',
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(
          viewport.widthOf('#link'),
          lessThanOrEqualTo(viewport.contentWidth),
        );
        expect(viewport.renderedFontSizeOf('#link'), 16);
        expect(viewport.renderedFontSizeOf('#body'), 16);
      },
    );
  });

  test('wraps a link that forbids wrapping inside a table cell', () async {
    // The cell grows to fit an unbreakable link, so the overflow is only
    // visible against the width the email itself can occupy.
    await withEmail(
      const EmailFixture(
        '<table width="900" style="width:900px"><tr>'
        '<td id="cell" style="font-size:15px">'
        '<a id="link" href="https://example.com/pull/12" '
        'style="white-space:nowrap;word-break:keep-all;font-size:15px">'
        'example.com/acme/widgets/pull/12/changes/0123456789abcdef0123456789'
        'abcdef01234567#diff-fedcba9876543210fedcba9876543210fedcba9876543210'
        'fedcba9876543210L42'
        '</a>'
        '</td></tr></table>',
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.renderedFontSizeOf('#link'), 15);
      },
    );
  });

  test('keeps the spacing of preformatted content while wrapping it', () async {
    await withEmail(
      EmailFixture(
        '<pre id="listing" style="white-space:pre;font-size:16px">'
        'col1    col2    col3    ${'x' * 160}'
        '</pre>',
      ),
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
      const EmailFixture(
        '<img id="banner" width="800" height="400" '
        'style="width:800px;height:400px" '
        'src="data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==">',
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.aspectRatioOf('#banner'), closeTo(2, 0.05));
      },
    );
  });

  test('breaks unbreakable cell text instead of shrinking it', () async {
    await withEmail(
      EmailFixture(
        '<table><tr>'
        '<td id="cell" style="font-size:16px">${'A' * 120}</td>'
        '</tr></table>',
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.renderedFontSizeOf('#cell'), 16);
      },
    );
  });

  test('scales a frame whose min-width survives the reflow', () async {
    await withEmail(
      const EmailFixture(
        '<table id="frame" style="min-width:640px;width:100%"><tr><td>'
        '<table style="width:640px"><tr>'
        '<td id="cell" style="font-size:15px">Build status report</td>'
        '</tr></table>'
        '</td></tr></table>',
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(
          viewport.widthOf('#frame'),
          lessThanOrEqualTo(viewport.contentWidth),
        );
      },
    );
  });

  test('reflows a fixed-width table before shrinking its text', () async {
    await withEmail(
      const EmailFixture(
        '<table id="grid" width="900" style="width:900px"><tr>'
        '<td id="cell" width="450" style="width:450px;padding:24px;font-size:16px">Column one</td>'
        '<td width="450" style="width:450px;padding:24px;font-size:16px">Column two</td>'
        '</tr></table>',
      ),
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

/// Above 600px the document stylesheet no longer forces tables to full width,
/// so the reflow has to resolve the declared widths on its own.
void verifyTableWidthsOutsideTheMobileBreakpoint() {
  const tabletWidth = 700;

  test('reflows a nested fixed-width table instead of scaling the outer one',
      () async {
    await withEmail(
      const EmailFixture(
        '<table width="1000" style="width:1000px"><tr><td>'
        '<table style="table-layout:fixed;width:900px"><tr>'
        '<td id="cell" style="width:450px;font-size:16px">Inner column one</td>'
        '<td style="width:450px;font-size:16px">Inner column two</td>'
        '</tr></table></td></tr></table>',
        viewportWidth: tabletWidth,
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.renderedFontSizeOf('#cell'), 16);
      },
    );
  });

  test('reflows cell widths declared in a stylesheet', () async {
    await withEmail(
      const EmailFixture(
        '<style>#grid { table-layout:fixed; width:900px; } #grid td { width:450px; }</style>'
        '<table id="grid"><tr>'
        '<td id="cell" style="font-size:16px">Column one</td>'
        '<td style="font-size:16px">Column two</td>'
        '</tr></table>',
        viewportWidth: tabletWidth,
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.renderedFontSizeOf('#cell'), 16);
      },
    );
  });
}

/// The relaxation must reach content that genuinely overflows and nothing
/// else, so these lock down the cases it has to leave alone.
void verifyDefensiveLayoutGuards() {
  test('keeps a short link that forbids wrapping on one line', () async {
    await withEmail(
      const EmailFixture(
        '<div style="font-size:16px">Sent on '
        '<a id="link" href="https://example.com" '
        'style="white-space:nowrap;word-break:keep-all;font-size:16px">'
        'Nov 3, 2026'
        '</a></div>',
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.whiteSpaceOf('#link'), 'nowrap');
        expect(viewport.renderedFontSizeOf('#link'), 16);
      },
    );
  });

  test('leaves a block that scrolls its own overflow untouched', () async {
    await withEmail(
      EmailFixture(
        '<div id="listing" style="white-space:nowrap;overflow-x:auto;'
        'width:100%;font-size:16px">'
        '${'token ' * 120}'
        '</div>',
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.whiteSpaceOf('#listing'), 'nowrap');
        expect(viewport.renderedFontSizeOf('#listing'), 16);
      },
    );
  });

  test('ignores a hidden link that has no measurable width', () async {
    await withEmail(
      const EmailFixture(
        '<div style="display:none">'
        '<a id="link" href="https://example.com/pull/12" '
        'style="white-space:nowrap;word-break:keep-all">'
        'example.com/acme/widgets/pull/12/changes/0123456789abcdef0123456789'
        'abcdef01234567#diff-fedcba9876543210fedcba9876543210fedcba9876543210'
        'fedcba9876543210L42'
        '</a>'
        '</div>'
        '<p id="body" style="font-size:16px">Visible body.</p>',
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.whiteSpaceOf('#link'), 'nowrap');
        expect(viewport.renderedFontSizeOf('#body'), 16);
      },
    );
  });

  test('wraps a link nested inside a non-wrapping span', () async {
    await withEmail(
      const EmailFixture(
        '<span id="holder" style="white-space:nowrap;font-size:16px">'
        '<a id="link" href="https://example.com/pull/12" '
        'style="white-space:nowrap;word-break:keep-all;font-size:16px">'
        'example.com/acme/widgets/pull/12/changes/0123456789abcdef0123456789'
        'abcdef01234567#diff-fedcba9876543210fedcba9876543210fedcba9876543210'
        'fedcba9876543210L42'
        '</a>'
        '</span>',
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(viewport.renderedFontSizeOf('#link'), 16);
      },
    );
  });

  test('wraps a non-wrapping link in a right-to-left email', () async {
    await withEmail(
      const EmailFixture(
        '<a id="link" href="https://example.com/pull/12" '
        'style="white-space:nowrap;word-break:keep-all;font-size:16px">'
        'example.com/acme/widgets/pull/12/changes/0123456789abcdef0123456789'
        'abcdef01234567#diff-fedcba9876543210fedcba9876543210fedcba9876543210'
        'fedcba9876543210L42'
        '</a>',
        direction: TextDirection.rtl,
      ),
      (viewport) async {
        expect(viewport.overflowsHorizontally, isFalse);
        expect(
          viewport.widthOf('#link'),
          lessThanOrEqualTo(viewport.contentWidth),
        );
        expect(viewport.renderedFontSizeOf('#link'), 16);
      },
    );
  });
}
