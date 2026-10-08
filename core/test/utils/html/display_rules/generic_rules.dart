import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:web/web.dart' as web;

import '../display_harness/display_case.dart';

/// One broken display rule, pointing at the element that breaks it.
class Violation {
  const Violation(this.rule, this.path, [this.detail = '']);

  final String rule;
  final String path;
  final String detail;

  String describe(DisplayCase displayCase) =>
      displayCase.failure(rule, path, detail);
}

/// A display rule: what it reports for one rendered case.
typedef DisplayRule = List<Violation> Function(DisplayRender render);

/// Rules that hold for every email on every viewer and width (IDs from the
/// rules inventory: C2/C4/C5/B9/B10/E3–E6, D1/E10, C8, C6).
const genericRules = <String, DisplayRule>{
  'G-overflow': overflowRule,
  'G-image-fit': imageFitRule,
  'G-text': textRule,
  'G-link-fill': linkFillRule,
  'G-rtl': rtlRule,
  'G-line-height': lineHeightRule,
  'G-word-split': wordSplitRule,
  'G-ascii-table': asciiTableRule,
};

/// Runs every generic rule on the email as first shown and, when a quote
/// toggle hides part of it, again after expanding it (quoted newsletters
/// overflow too). G-text is judged on the expanded state only, so an email
/// that is entirely a collapsed quote still has to reveal content.
Future<List<Violation>> runGenericRules(DisplayRender render) async {
  final seen = <String>{};
  final violations = <Violation>[];
  void collect(Iterable<Violation> found) {
    for (final violation in found) {
      if (seen.add('${violation.rule}|${violation.path}|${violation.detail}')) {
        violations.add(violation);
      }
    }
  }

  final frame = render.frame;
  final collapsed = frame.hasQuoteToggle && !frame.isQuoteExpanded;
  for (final entry in genericRules.entries) {
    if (collapsed && entry.value == textRule) continue;
    collect(entry.value(render));
  }
  if (collapsed) {
    await frame.toggleQuote();
    for (final rule in genericRules.values) {
      collect(rule(render));
    }
  }
  return violations;
}

String _px(num value) => '${value.toStringAsFixed(1)}px';

/// Nothing in the email sticks out of the pane by more than 1px: no element
/// box on either side (only the innermost are reported, their ancestors
/// overflow because of them), no text running past its box, and
/// `.tmail-content` does not scroll sideways (`body` hides that overflow).
List<Violation> overflowRule(DisplayRender render) {
  final frame = render.frame;
  final overflows = frame.overflows();
  return [
    for (final overflow in overflows)
      if (!overflows.any((other) => other.path.startsWith('${overflow.path} > ')))
        Violation('G-overflow', overflow.path, '+${_px(overflow.pixels)}'),
    for (final overflow in frame.contentOverflows())
      Violation('G-overflow', overflow.path, 'content +${_px(overflow.pixels)} past its box'),
    if (frame.scrollsHorizontally)
      Violation(
        'G-overflow',
        '.tmail-content',
        'scrolls sideways: ${frame.content.scrollWidth} > ${frame.content.clientWidth}px',
      ),
  ];
}

/// Every rendered image fits the pane (after any zoom, which is what the
/// user sees) and keeps its shape: the rendered ratio matches, within 2%,
/// either the sender's declared width/height or the image file itself.
List<Violation> imageFitRule(DisplayRender render) {
  final frame = render.frame;
  final declared = _declaredImageRatios(render.transformedHtml);
  final guessedSizes = [
    for (final image in html_parser.parse(render.transformedHtml).querySelectorAll('img'))
      (image.attributes['src'] ?? '').contains('fixture.invalid/est/'),
  ];
  final images = frame.images;
  final violations = <Violation>[];
  for (var i = 0; i < images.length; i++) {
    final image = images[i];
    if (image.width <= 2 || image.height <= 2) continue; // hidden or a pixel
    if (image.width > frame.contentWidth + 1) {
      violations.add(Violation(
        'G-image-fit',
        image.path,
        '${_px(image.width)} wide in a ${_px(frame.contentWidth)} pane',
      ));
    }
    final rendered = image.width / image.height;
    final natural = image.naturalHeight == 0
        ? null
        : image.naturalWidth / image.naturalHeight;
    // A guessed placeholder size (`fixture.invalid/est/`) says nothing about
    // the real image's shape, so only the pane width is checked for it.
    final guessed = i < guessedSizes.length && guessedSizes[i];
    final intended = guessed
        ? const <double>[]
        : [
            if (i < declared.length && declared[i] != null) declared[i]!,
            if (natural != null) natural,
          ];
    if (intended.isNotEmpty &&
        intended.every((ratio) => (rendered / ratio - 1).abs() > 0.02)) {
      violations.add(Violation(
        'G-image-fit',
        image.path,
        'aspect ${rendered.toStringAsFixed(2)}, expected '
            '${intended.map((r) => r.toStringAsFixed(2)).join(' or ')}',
      ));
    }
  }
  return violations;
}

/// Width/height the sender declared for each `<img>`, in document order,
/// from attributes or inline px styles; null when one side is missing.
List<double?> _declaredImageRatios(String html) {
  double? size(dom.Element image, String side) {
    final style = image.attributes['style'] ?? '';
    final css = RegExp('(?:^|;)\\s*$side\\s*:\\s*([\\d.]+)px', caseSensitive: false)
        .firstMatch(style);
    return double.tryParse(css?.group(1) ?? image.attributes[side] ?? '');
  }

  return [
    for (final image in html_parser.parse(html).querySelectorAll('img'))
      switch ((size(image, 'width'), size(image, 'height'))) {
        (final double width, final double height) when width > 0 && height > 0 =>
          width / height,
        _ => null,
      },
  ];
}

/// The email shows something: text or at least one rendered image (unless
/// the fixture allows an empty body). Run on the final state, after any
/// quote toggle was expanded (see [runGenericRules]).
List<Violation> textRule(DisplayRender render) {
  if (render.displayCase.fixture.allowEmptyBody) return const [];
  final frame = render.frame;
  final hasImage = frame.images.any((image) => image.width > 2 && image.height > 2);
  if (frame.visibleText.trim().isNotEmpty || hasImage) return const [];
  return const [Violation('G-text', '.tmail-content', 'nothing visible')];
}

/// Under the 600px media query every link is stretched to the available
/// width (`a:not(.tmail-file-link-card) { width: -webkit-fill-available }`);
/// a Drive file card is excluded and must keep the width it declares. (A
/// link pushing past the pane is a G-overflow violation.)
List<Violation> linkFillRule(DisplayRender render) {
  final frame = render.frame;
  if (frame.paneWidth > 600) return const [];
  final violations = <Violation>[];
  for (final card in frame.queryAll('.tmail-content a.tmail-file-link-card')) {
    final declared = double.tryParse(
      RegExp(r'(?:^|;)\s*width\s*:\s*([\d.]+)px')
              .firstMatch(card.getAttribute('style') ?? '')
              ?.group(1) ??
          '',
    );
    if (declared == null) {
      violations.add(Violation('G-link-fill', frame.cssPath(card), 'file card declares no width'));
      continue;
    }
    if (declared > frame.contentWidth) continue;
    final width = card.getBoundingClientRect().width / frame.zoomOf(card);
    if ((width - declared).abs() > 1) {
      violations.add(Violation(
        'G-link-fill',
        frame.cssPath(card),
        'file card ${_px(width)} instead of ${_px(declared)}',
      ));
    }
  }
  return violations;
}

/// A right-to-left fixture renders with `dir="rtl"` on `<body>`; its
/// overflow (on the left) is covered by [overflowRule].
List<Violation> rtlRule(DisplayRender render) {
  if (!render.displayCase.fixture.rtl) return const [];
  final body = render.frame.document.body as web.HTMLElement;
  if (body.dir == 'rtl') return const [];
  return [Violation('G-rtl', 'body', 'dir="${body.dir}"')];
}

const _showText = 4; // NodeFilter.SHOW_TEXT

/// Text nodes inside [root] that hold more than whitespace.
List<web.Text> _textNodes(DisplayFrame frame, web.Node root) {
  final walker = frame.document.createTreeWalker(root, _showText);
  final nodes = <web.Text>[];
  for (var node = walker.nextNode(); node != null; node = walker.nextNode()) {
    final text = node as web.Text;
    if (text.data.replaceAll(' ', ' ').trim().isNotEmpty) nodes.add(text);
  }
  return nodes;
}

web.DOMRectList _rects(DisplayFrame frame, web.Text node, int start, int end) =>
    (frame.document.createRange()
          ..setStart(node, start)
          ..setEnd(node, end))
        .getClientRects();

/// Distinct line tops of [rects]: how many lines the measured text spans.
int _lineCount(web.DOMRectList rects) =>
    {for (var i = 0; i < rects.length; i++) rects.item(i)!.top.round()}.length;

/// Lines of text never overlap: when text wraps, a rendered `line-height`
/// below 0.8 of the font size stacks its lines on top of each other (one
/// line with a tight line height overlaps nothing).
List<Violation> lineHeightRule(DisplayRender render) {
  final frame = render.frame;
  final seen = <web.Element>{};
  final violations = <Violation>[];
  for (final text in _textNodes(frame, frame.content)) {
    final element = text.parentElement;
    if (element == null || seen.contains(element)) continue;
    if (_lineCount(_rects(frame, text, 0, text.data.length)) < 2) continue;
    seen.add(element);
    final style = frame.computedStyle(element);
    if (!style.lineHeight.endsWith('px')) continue; // `normal`
    final lineHeight = double.parse(style.lineHeight.replaceAll('px', ''));
    final fontSize = double.tryParse(style.fontSize.replaceAll('px', '')) ?? 0;
    if (fontSize > 1 && lineHeight < fontSize * 0.8) {
      violations.add(Violation(
        'G-line-height',
        frame.cssPath(element),
        'line-height ${_px(lineHeight)} for ${_px(fontSize)} text',
      ));
    }
  }
  return violations;
}

final _tokenPattern = RegExp(r'\S+');
final _wordPattern = RegExp(r'[\p{L}\p{N}]{2,}', unicode: true);

double _width(web.DOMRectList rects) {
  var width = 0.0;
  for (var i = 0; i < rects.length; i++) {
    width += rects.item(i)!.width;
  }
  return width;
}

/// Whether TMail, not the sender, lets [element] break inside words: the
/// `overflow-wrap: anywhere` the cell transformer adds (the sender never
/// wrote it), or a `word-break` a viewer script set on the way up to [cell].
/// A sender who asks for `break-word` / `break-all` gets what they asked for.
bool _tmailBreaksWords(DisplayFrame frame, web.Element element, web.Element cell, bool senderWroteAnywhere) {
  final style = frame.computedStyle(element);
  if (style.overflowWrap == 'anywhere' && style.wordBreak == 'normal') return !senderWroteAnywhere;
  if (style.wordBreak == 'normal') return false;
  for (web.Element? at = element; at != null; at = at.parentElement) {
    if (frame.changedByScript(at, 'word-break')) return true;
    if (at == cell) break;
  }
  return false;
}

/// A word in a table cell is never cut across two lines by TMail unless its
/// token (the run between spaces, a URL say) is wider than the pane: columns
/// are not squeezed below their longest word. Breaks at `-` or `/` are
/// normal, and so are cuts the sender's own CSS asks for.
List<Violation> wordSplitRule(DisplayRender render) {
  final frame = render.frame;
  final senderWroteAnywhere =
      RegExp(r'overflow-wrap\s*:\s*anywhere', caseSensitive: false).hasMatch(render.displayCase.fixture.html);
  final violations = <Violation>[];
  final reported = <web.Element>{};
  for (final cell in frame.queryAll('.tmail-content td, .tmail-content th')) {
    for (final text in _textNodes(frame, cell)) {
      final element = text.parentElement!;
      if (element.closest('td, th') != cell || reported.contains(cell)) continue;
      if (!_tmailBreaksWords(frame, element, cell, senderWroteAnywhere)) continue;
      for (final token in _tokenPattern.allMatches(text.data)) {
        if (reported.contains(cell)) break;
        final tokenRects = _rects(frame, text, token.start, token.end);
        if (_lineCount(tokenRects) < 2 || _width(tokenRects) > frame.contentWidth) continue;
        for (final word in _wordPattern.allMatches(token.group(0)!)) {
          final start = token.start + word.start;
          final lines = _lineCount(_rects(frame, text, start, start + word.end - word.start));
          if (lines < 2) continue;
          reported.add(cell);
          violations.add(Violation(
            'G-word-split',
            frame.cssPath(cell),
            'a ${word.end - word.start}-letter word is cut over $lines lines',
          ));
          break;
        }
      }
    }
  }
  return violations;
}

final _asciiTableLine = RegExp(r'^\s*[+|].*[+|]\s*$');

/// A plain-text ASCII table keeps its columns aligned: every border and row
/// line of one table renders at the same width.
List<Violation> asciiTableRule(DisplayRender render) {
  if (!render.displayCase.fixture.isPlainText) return const [];
  final frame = render.frame;
  final widths = <double>[];
  web.Element? block;
  for (final text in _textNodes(frame, frame.content)) {
    var offset = 0;
    for (final line in text.data.split('\n')) {
      if (_asciiTableLine.hasMatch(line) && line.trim().length > 2) {
        final trimmed = line.trimRight();
        widths.add(_width(_rects(frame, text, offset, offset + trimmed.length)));
        block ??= text.parentElement;
      }
      offset += line.length + 1;
    }
  }
  if (widths.length < 2) return const [];
  final spread = widths.reduce((a, b) => a > b ? a : b) - widths.reduce((a, b) => a < b ? a : b);
  if (spread <= 1) return const [];
  return [
    Violation('G-ascii-table', frame.cssPath(block!), 'table lines differ by ${_px(spread)}'),
  ];
}
