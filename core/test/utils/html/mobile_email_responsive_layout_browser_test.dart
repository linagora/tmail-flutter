@TestOn('chrome')

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mobile_email_responsive_layout_fixture.dart';

const _readableFontSize = 12;

/// An unbreakable URL, long enough to overflow a phone viewport on its own.
const _unbreakableLink =
    'example.com/acme/widgets/pull/12/changes/0123456789abcdef0123456789'
    'abcdef01234567#diff-fedcba9876543210fedcba9876543210fedcba9876543210'
    'fedcba9876543210L42';

const _noWrapLinkStyle = 'white-space:nowrap;word-break:keep-all;font-size:16px';

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
  testEmailLayout(
    'keeps a plain email untouched',
    const EmailFixture(
      '<p id="body" style="font-size:16px">A plain paragraph.</p>',
    ),
    const [ElementLayout('#body', fontSize: 16)],
  );

  testEmailLayout(
    'keeps a responsive table untouched',
    const EmailFixture(
      '<table style="width:100%"><tr>'
      '<td id="cell" style="font-size:16px">Cell A</td>'
      '<td style="font-size:16px">Cell B</td>'
      '</tr></table>',
    ),
    const [ElementLayout('#cell', fontSize: 16)],
  );
}

void verifyFixedWidthWrapperReflow() {
  const fixedWidthWrapper = '<div id="wrapper" style="width:790px">'
      '<p id="body" style="font-size:16px">Newsletter paragraph.</p>'
      '</div>';

  testEmailLayout(
    'reflows a fixed-width wrapper instead of shrinking its text',
    const EmailFixture(fixedWidthWrapper),
    const [
      ElementLayout('#wrapper', width: ElementWidth.fillsContent),
      ElementLayout('#body', fontSize: 16),
    ],
  );

  testEmailLayout(
    'reflows a fixed-width wrapper in a right-to-left email',
    const EmailFixture(fixedWidthWrapper, direction: TextDirection.rtl),
    const [
      ElementLayout('#wrapper', width: ElementWidth.fillsContent),
      ElementLayout('#body', fontSize: 16),
    ],
  );

  testEmailLayout(
    'reflows a wrapper whose ancestor clips the overflow',
    const EmailFixture(
      '<div style="overflow:hidden;width:100%">'
      '<div id="wrapper" style="width:900px;font-size:16px">Clipped body</div>'
      '</div>',
    ),
    const [
      ElementLayout(
        '#wrapper',
        width: ElementWidth.fillsContent,
        fontSize: 16,
      ),
    ],
  );
}

void verifyNonWrappingContentReflow() {
  testEmailLayout(
    'wraps non-wrapping content that overflows the viewport',
    EmailFixture(
      '<div id="row" style="white-space:nowrap;font-size:16px">'
      '${'word ' * 120}'
      '</div>',
    ),
    const [
      ElementLayout('#row', width: ElementWidth.fitsContent, fontSize: 16),
    ],
  );

  testEmailLayout(
    'wraps a non-wrapping table cell instead of scaling the table',
    EmailFixture(
      '<table><tr>'
      '<td id="cell" style="white-space:nowrap;font-size:16px">'
      '${'word ' * 40}'
      '</td>'
      '</tr></table>',
    ),
    const [ElementLayout('#cell', whiteSpace: 'normal', fontSize: 16)],
  );

  testEmailLayout(
    'wraps a link that forbids wrapping instead of shrinking it',
    const EmailFixture(
      '<div id="body" style="font-size:16px">Forwarded message</div>'
      '<a id="link" href="https://example.com/pull/12" rel="noreferrer" '
      'style="$_noWrapLinkStyle">$_unbreakableLink</a>',
    ),
    const [
      ElementLayout('#link', width: ElementWidth.fitsContent, fontSize: 16),
      ElementLayout('#body', fontSize: 16),
    ],
  );

  // The cell grows to fit an unbreakable link, so the overflow is only visible
  // against the width the email itself can occupy.
  testEmailLayout(
    'wraps a link that forbids wrapping inside a table cell',
    const EmailFixture(
      '<table width="900" style="width:900px"><tr>'
      '<td id="cell" style="font-size:15px">'
      '<a id="link" href="https://example.com/pull/12" '
      'style="white-space:nowrap;word-break:keep-all;font-size:15px">'
      '$_unbreakableLink</a>'
      '</td></tr></table>',
    ),
    const [ElementLayout('#link', fontSize: 15)],
  );

  testEmailLayout(
    'keeps the spacing of preformatted content while wrapping it',
    EmailFixture(
      '<pre id="listing" style="white-space:pre;font-size:16px">'
      'col1    col2    col3    ${'x' * 160}'
      '</pre>',
    ),
    const [ElementLayout('#listing', whiteSpace: 'pre-wrap', fontSize: 16)],
  );
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

  testEmailLayout(
    'breaks unbreakable cell text instead of shrinking it',
    EmailFixture(
      '<table><tr>'
      '<td id="cell" style="font-size:16px">${'A' * 120}</td>'
      '</tr></table>',
    ),
    const [ElementLayout('#cell', fontSize: 16)],
  );

  testEmailLayout(
    'scales a frame whose min-width survives the reflow',
    const EmailFixture(
      '<table id="frame" style="min-width:640px;width:100%"><tr><td>'
      '<table style="width:640px"><tr>'
      '<td id="cell" style="font-size:15px">Build status report</td>'
      '</tr></table>'
      '</td></tr></table>',
    ),
    const [ElementLayout('#frame', width: ElementWidth.fitsContent)],
  );

  testEmailLayout(
    'reflows a fixed-width table before shrinking its text',
    const EmailFixture(
      '<table id="grid" width="900" style="width:900px"><tr>'
      '<td id="cell" width="450" style="width:450px;padding:24px;font-size:16px">Column one</td>'
      '<td width="450" style="width:450px;padding:24px;font-size:16px">Column two</td>'
      '</tr></table>',
    ),
    [
      const ElementLayout('#grid', width: ElementWidth.fitsContent),
      ElementLayout('#cell', fontSize: greaterThanOrEqualTo(_readableFontSize)),
    ],
  );
}

/// Above 600px the document stylesheet no longer forces tables to full width,
/// so the reflow has to resolve the declared widths on its own.
void verifyTableWidthsOutsideTheMobileBreakpoint() {
  const tabletWidth = 700;

  testEmailLayout(
    'reflows a nested fixed-width table instead of scaling the outer one',
    const EmailFixture(
      '<table width="1000" style="width:1000px"><tr><td>'
      '<table style="table-layout:fixed;width:900px"><tr>'
      '<td id="cell" style="width:450px;font-size:16px">Inner column one</td>'
      '<td style="width:450px;font-size:16px">Inner column two</td>'
      '</tr></table></td></tr></table>',
      viewportWidth: tabletWidth,
    ),
    const [ElementLayout('#cell', fontSize: 16)],
  );

  testEmailLayout(
    'reflows cell widths declared in a stylesheet',
    const EmailFixture(
      '<style>#grid { table-layout:fixed; width:900px; } #grid td { width:450px; }</style>'
      '<table id="grid"><tr>'
      '<td id="cell" style="font-size:16px">Column one</td>'
      '<td style="font-size:16px">Column two</td>'
      '</tr></table>',
      viewportWidth: tabletWidth,
    ),
    const [ElementLayout('#cell', fontSize: 16)],
  );
}

/// The relaxation must reach content that genuinely overflows and nothing
/// else, so these lock down the cases it has to leave alone.
void verifyDefensiveLayoutGuards() {
  testEmailLayout(
    'keeps a short link that forbids wrapping on one line',
    const EmailFixture(
      '<div style="font-size:16px">Sent on '
      '<a id="link" href="https://example.com" '
      'style="$_noWrapLinkStyle">Nov 3, 2026</a></div>',
    ),
    const [ElementLayout('#link', whiteSpace: 'nowrap', fontSize: 16)],
  );

  testEmailLayout(
    'leaves a block that scrolls its own overflow untouched',
    EmailFixture(
      '<div id="listing" style="white-space:nowrap;overflow-x:auto;'
      'width:100%;font-size:16px">'
      '${'token ' * 120}'
      '</div>',
    ),
    const [ElementLayout('#listing', whiteSpace: 'nowrap', fontSize: 16)],
  );

  testEmailLayout(
    'ignores a hidden link that has no measurable width',
    const EmailFixture(
      '<div style="display:none">'
      '<a id="link" href="https://example.com/pull/12" '
      'style="white-space:nowrap;word-break:keep-all">$_unbreakableLink</a>'
      '</div>'
      '<p id="body" style="font-size:16px">Visible body.</p>',
    ),
    const [
      ElementLayout('#link', whiteSpace: 'nowrap'),
      ElementLayout('#body', fontSize: 16),
    ],
  );

  testEmailLayout(
    'wraps a link nested inside a non-wrapping span',
    const EmailFixture(
      '<span id="holder" style="white-space:nowrap;font-size:16px">'
      '<a id="link" href="https://example.com/pull/12" '
      'style="$_noWrapLinkStyle">$_unbreakableLink</a>'
      '</span>',
    ),
    const [ElementLayout('#link', fontSize: 16)],
  );

  testEmailLayout(
    'wraps a non-wrapping link in a right-to-left email',
    const EmailFixture(
      '<a id="link" href="https://example.com/pull/12" '
      'style="$_noWrapLinkStyle">$_unbreakableLink</a>',
      direction: TextDirection.rtl,
    ),
    const [ElementLayout('#link', width: ElementWidth.fitsContent, fontSize: 16)],
  );
}
