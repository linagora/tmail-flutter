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
