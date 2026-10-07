import 'package:core/presentation/constants/constants_ui.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:web/web.dart' as web;

import '../../../fixtures/html_emails/html_email_corpus_fixture.dart';
import '../display_harness/display_case.dart';
import 'generic_rules.dart';

/// What a fixture's sidecar `expect` label requires; may click or scroll,
/// so each label runs on its own fresh render.
typedef ExpectChecker = Future<List<Violation>> Function(DisplayRender render);

/// One checker per `HtmlEmailExpect` label (IDs from the rules inventory).
const expectCheckers = <HtmlEmailExpect, ExpectChecker>{
  HtmlEmailExpect.fullDisplay: fullDisplayChecker,
  HtmlEmailExpect.lazyImages: lazyImagesChecker,
  HtmlEmailExpect.autoScale: autoScaleChecker,
  HtmlEmailExpect.noScale: noScaleChecker,
  HtmlEmailExpect.quoteToggle: quoteToggleChecker,
  HtmlEmailExpect.noQuoteToggle: noQuoteToggleChecker,
};

/// `expect` checkers apply to the native and web viewers (the iOS viewer
/// runs generic rules only); `autoScale` needs the native responsive script.
bool expectApplies(HtmlEmailExpect expect, DisplayViewer viewer) =>
    switch (expect) {
      HtmlEmailExpect.autoScale => viewer == DisplayViewer.native,
      _ => viewer != DisplayViewer.ios,
    };

bool _isRendered(web.Element element) => element.getClientRects().length > 0;

/// An image the sender hid on purpose (`width="0"` or `height="0"`).
bool _hiddenBySender(web.Element image) =>
    image.getAttribute('width') == '0' || image.getAttribute('height') == '0';

/// fullDisplay (C, F3): the generic rules hold (collapsed and expanded),
/// every shown image has a box, and the email body is taller than 0 and
/// below the native viewer cap (`ConstantsUI.htmlContentMaxHeight`).
Future<List<Violation>> fullDisplayChecker(DisplayRender render) async {
  final frame = render.frame;
  final violations = await runGenericRules(render);
  for (final image in frame.images) {
    if (!_isRendered(image.element) || _hiddenBySender(image.element)) continue;
    if (image.width <= 0 || image.height <= 0) {
      violations.add(Violation('fullDisplay', image.path,
          'image box ${image.width}x${image.height}'));
    }
  }
  final height = frame.content.getBoundingClientRect().height;
  if (height <= 0 || height >= ConstantsUI.htmlContentMaxHeight) {
    violations.add(Violation('fullDisplay', '.tmail-content', 'body height ${height}px'));
  }
  return violations;
}

/// lazyImages (B5, B6, D2): on the transform output, every remote `<img>`
/// without its own `loading` becomes `loading="lazy"` (a sender's value is
/// kept, as `ImageTransformer` does) and every inline background image moves
/// to `lazy` + `data-src`. In the frame, a lazy background below the fold is
/// still unloaded, and once scrolled into view gets exactly its `data-src`.
Future<List<Violation>> lazyImagesChecker(DisplayRender render) async {
  final violations = <Violation>[];
  final source = html_parser.parse(render.displayCase.fixture.html).querySelectorAll('img');
  final transformed = html_parser.parse(render.transformedHtml);
  final images = transformed.querySelectorAll('img');
  final remote = RegExp(r'^https?://', caseSensitive: false);
  for (var i = 0; i < images.length; i++) {
    final src = images[i].attributes['src'] ?? '';
    final senderLoading = i < source.length ? source[i].attributes['loading'] : null;
    final expected = senderLoading ?? 'lazy';
    if (remote.hasMatch(src) && images[i].attributes['loading'] != expected) {
      violations.add(Violation('lazyImages', 'img[src="$src"]',
          'loading="${images[i].attributes['loading']}", expected "$expected"'));
    }
  }
  for (final element in transformed.querySelectorAll('[style]')) {
    final style = element.attributes['style']!;
    if (RegExp(r'background-image\s*:\s*url\(', caseSensitive: false).hasMatch(style)) {
      violations.add(Violation('lazyImages', element.localName ?? '?',
          'background-image still inline: $style'));
    }
  }
  for (final element in transformed.querySelectorAll('[lazy]')) {
    if ((element.attributes['data-src'] ?? '').isEmpty) {
      violations.add(Violation('lazyImages', element.localName ?? '?', 'lazy without data-src'));
    }
  }

  final frame = render.frame;
  final viewportBottom = web.window.innerHeight;
  for (final element in frame.queryAll('.tmail-content [data-src]')) {
    final path = frame.cssPath(element);
    final dataSrc = element.getAttribute('data-src')!;
    final style = (element as web.HTMLElement).style;
    final belowFold = frame.topInWindow + element.getBoundingClientRect().top > viewportBottom;
    if (belowFold && (!element.hasAttribute('lazy') || style.backgroundImage.isNotEmpty)) {
      violations.add(Violation('lazyImages', path, 'loaded before it was scrolled into view'));
    }
    await frame.scrollIntoView(element);
    if (element.hasAttribute('lazy') || !style.backgroundImage.contains(dataSrc)) {
      violations.add(Violation('lazyImages', path,
          'background not restored to its data-src after scrolling into view'));
    }
  }
  return violations;
}

/// Which responsive path the native script took for an email.
enum AutoScalePath { none, reflow, zoom }

AutoScalePath autoScalePathOf(DisplayFrame frame) {
  if (frame.queryAll('.tmail-content .tmail-responsive-scale').isNotEmpty) {
    return AutoScalePath.zoom;
  }
  if (frame.queryAll('.tmail-content .tmail-responsive-layout').isNotEmpty) {
    return AutoScalePath.reflow;
  }
  return AutoScalePath.none;
}

/// autoScale (E6, E7, E9): the too-wide email is reflowed or zoomed and no
/// longer overflows. Every element the script zoomed has `zoom` < 1 (no font
/// floor on that path). At a pane ≤ 480, text whose size the script changed
/// stays ≥ 12px and cell padding it changed stays ≤ 12px. "Changed" is
/// against the sender's own inline style, so a sender `!important` is not
/// mistaken for the script.
Future<List<Violation>> autoScaleChecker(DisplayRender render) async {
  final frame = render.frame;
  final violations = <Violation>[
    for (final violation in overflowRule(render))
      Violation('autoScale', violation.path, 'still overflows ${violation.detail}'),
  ];
  if (autoScalePathOf(frame) == AutoScalePath.none) {
    violations.add(const Violation('autoScale', '.tmail-content', 'neither reflowed nor zoomed'));
  }
  for (final element in frame.queryAll('.tmail-content .tmail-responsive-scale')) {
    final zoom = double.tryParse(frame.computedStyle(element).zoom) ?? 1;
    if (zoom >= 1) {
      violations.add(Violation('autoScale', frame.cssPath(element), 'scaled but zoom $zoom'));
    }
  }
  if (frame.paneWidth <= 480) {
    for (final element in frame.queryAll('.tmail-content .tmail-responsive-layout, '
        '.tmail-content .tmail-responsive-layout *')) {
      if (frame.changedByScript(element, 'font-size') &&
          frame.renderedFontSize(element) < 12 - 0.01) {
        violations.add(Violation('autoScale', frame.cssPath(element),
            'shrunk to ${frame.renderedFontSize(element).toStringAsFixed(2)}px'));
      }
      for (final side in ['padding-left', 'padding-right']) {
        if (!frame.changedByScript(element, side)) continue;
        final value = frame.computedStyle(element).getPropertyValue(side);
        if ((double.tryParse(value.replaceAll('px', '')) ?? 0) > 12) {
          violations.add(Violation('autoScale', frame.cssPath(element), '$side $value'));
        }
      }
    }
  }
  return violations;
}

/// What the script changed for [autoScaleChecker]'s reflow path at a pane
/// ≤ 480 (shrunk text, capped padding); lets a fixture pin that the path
/// really ran.
({int shrunkText, int cappedPadding}) reflowChangesOf(DisplayFrame frame) {
  var shrunkText = 0;
  var cappedPadding = 0;
  for (final element in frame.queryAll('.tmail-content .tmail-responsive-layout *')) {
    if (frame.changedByScript(element, 'font-size')) shrunkText++;
    if (frame.changedByScript(element, 'padding-left') ||
        frame.changedByScript(element, 'padding-right')) {
      cappedPadding++;
    }
  }
  return (shrunkText: shrunkText, cappedPadding: cappedPadding);
}

/// noScale (E1): an email that fits is left as the sender wrote it: nothing
/// reflowed or zoomed, no inline style rewritten (fonts, wrapping), and it
/// still wraps inside the pane. Images are skipped: the normalize script
/// always adds its responsive defaults to them.
Future<List<Violation>> noScaleChecker(DisplayRender render) async {
  final frame = render.frame;
  final violations = <Violation>[
    for (final violation in overflowRule(render))
      Violation('noScale', violation.path, 'overflows ${violation.detail}'),
  ];
  for (final element in frame.queryAll('.tmail-content *')) {
    final zoom = double.tryParse(frame.computedStyle(element).zoom) ?? 1;
    final changed = element.classList.contains('tmail-responsive-scale') ||
        element.classList.contains('tmail-responsive-layout') ||
        (zoom - 1).abs() > 0.001 ||
        (element.localName != 'img' && frame.styleChangedByScript(element));
    if (changed) {
      violations.add(Violation('noScale', frame.cssPath(element),
          'changed: style="${element.getAttribute('style')}"'));
    }
  }
  return violations;
}

/// The blockquote `HtmlUtils.addQuoteToggle` targets: the last direct
/// blockquote of the container, else of the first `div` level (≤ 2) that has
/// one.
web.Element? _expectedToggledQuote(DisplayFrame frame) {
  for (var level = 0; level <= 2; level++) {
    final quotes = frame.queryAll('.quote-toggle-container${' > div' * level} > blockquote');
    if (quotes.isNotEmpty) return quotes.last;
  }
  return null;
}

/// quoteToggle (D3, D4, E8, E13): the toggle sits right before the expected
/// blockquote, starts collapsed, expands on click, on native the expanded
/// email still fits, and at a pane ≤ 480 the text of a reflowed quote is
/// ≥ 13px.
Future<List<Violation>> quoteToggleChecker(DisplayRender render) async {
  final frame = render.frame;
  final button = frame.query('.quote-toggle-button');
  if (button == null) {
    return const [Violation('quoteToggle', '.quote-toggle-button', 'missing')];
  }
  final violations = <Violation>[];
  final expected = _expectedToggledQuote(frame);
  if (expected == null || button.nextElementSibling != expected) {
    violations.add(Violation('quoteToggle', frame.cssPath(button),
        'not right before ${expected == null ? 'a reachable blockquote' : frame.cssPath(expected)}'));
  }
  if (frame.isQuoteExpanded) {
    violations.add(const Violation('quoteToggle', 'blockquote', 'not collapsed by default'));
  }
  await frame.toggleQuote();
  if (!frame.isQuoteExpanded) {
    violations.add(const Violation('quoteToggle', 'blockquote', 'does not expand on click'));
  }
  // E13: the native responsive script lays the email out again when a quote
  // opens. Web has no such script; its overflow is reported by G-overflow.
  if (render.displayCase.viewer == DisplayViewer.native) {
    for (final violation in overflowRule(render)) {
      violations.add(Violation('quoteToggle', violation.path,
          'overflows after expanding ${violation.detail}'));
    }
  }
  if (frame.paneWidth <= 480) {
    for (final quote in frame.queryAll('.tmail-content blockquote.tmail-responsive-quote')) {
      for (final element in [quote, ...frame.queryAll('${frame.cssPath(quote)} *')]) {
        if (!_hasOwnText(element)) continue;
        final size = frame.renderedFontSize(element);
        if (size < 13 - 0.01) {
          violations.add(Violation('quoteToggle', frame.cssPath(element),
              'quote text ${size.toStringAsFixed(2)}px'));
        }
      }
    }
  }
  return violations;
}

bool _hasOwnText(web.Element element) {
  final nodes = element.childNodes;
  for (var i = 0; i < nodes.length; i++) {
    final node = nodes.item(i)!;
    if (node.nodeType == web.Node.TEXT_NODE && (node.textContent ?? '').trim().isNotEmpty) {
      return true;
    }
  }
  return false;
}

/// noQuoteToggle (D3): a blockquote nested deeper than two `div` levels is
/// out of the toggle's reach, so no button is added.
Future<List<Violation>> noQuoteToggleChecker(DisplayRender render) async {
  final frame = render.frame;
  final violations = <Violation>[];
  if (frame.query('blockquote') == null) {
    violations.add(const Violation('noQuoteToggle', '.tmail-content', 'fixture has no blockquote'));
  }
  final button = frame.query('.quote-toggle-button');
  if (button != null) {
    violations.add(Violation('noQuoteToggle', frame.cssPath(button), 'toggle added'));
  }
  return violations;
}
