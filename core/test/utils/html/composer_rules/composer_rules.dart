import 'dart:math';

import 'package:html/dom.dart';

import '../../../fixtures/html_emails/html_email_corpus_fixture.dart';
import '../display_rules/content_preservation.dart';

/// Rules for the pipelines that feed the composer. Each returns the failures
/// it found, empty when the rule holds.

/// The body words and the links of [fixture] survive the pipeline.
List<String> preservationFailures(HtmlEmailCorpusFixture fixture, String out) {
  if (fixture.allowEmptyBody) return const [];
  final kept = bodyWordPreservation(fixture.html, out);
  return [
    if (kept < fixture.minPreservation)
      'only ${(kept * 100).toStringAsFixed(1)}% of the words kept',
    if (bodyLinkDestinations(out).join(' ') !=
        bodyLinkDestinations(fixture.html).join(' '))
      'link destinations changed',
  ];
}

/// A second pass over the output changes nothing.
List<String> idempotenceFailures(Document once, Document twice) {
  final first = once.outerHtml;
  final second = twice.outerHtml;
  if (first == second) return const [];
  final end = min(first.length, second.length);
  var at = 0;
  while (at < end && first[at] == second[at]) {
    at++;
  }
  String window(String html) => html.substring(at, min(html.length, at + 120));
  return ['second pass differs at $at: "${window(first)}" vs "${window(second)}"'];
}

final _overflowWrap = RegExp(r'overflow-wrap:\s*anywhere');

/// `loading="lazy"` is not counted: a standard attribute other clients handle.
/// `tmail-signature-blocked` is not counted either: `SignatureTransformer`
/// marks the quoted signature on purpose.
Map<String, int> _displayMarkers(Document document) {
  int count(String selector) => document.querySelectorAll(selector).length;
  return {
    'lazy attribute': count('[lazy]'),
    'data-src': count('[data-src]'),
    'overflow-wrap: anywhere': document
        .querySelectorAll('[style]')
        .where((element) => _overflowWrap.hasMatch(element.attributes['style']!))
        .length,
    'tmail-responsive class': count('[class*="tmail-responsive-"]'),
    'quote toggle button': count('.quote-toggle-button'),
  };
}

/// The pipeline adds no markup that only the display viewers use.
List<String> displayOnlyLeaks(Document source, Document out) {
  final before = _displayMarkers(source);
  final after = _displayMarkers(out);
  return [
    for (final marker in before.keys)
      if (after[marker]! > before[marker]!)
        '$marker: ${before[marker]} in the source, ${after[marker]} in the output',
  ];
}

/// Every drive card stays uneditable, and at least one card is there.
List<String> driveCardFailures(Document out) {
  final cards = out.querySelectorAll('a.tmail-file-link-card');
  if (cards.isEmpty) return const ['no drive card in the output'];
  return [
    for (final card in cards)
      if (card.attributes['contenteditable'] != 'false')
        'drive card without contenteditable="false"',
  ];
}

String _normalizedStyle(Element element) => element.attributes['style']!
    .split(';')
    .map((declaration) => declaration.trim())
    .where(
      (declaration) =>
          declaration.isNotEmpty &&
          !declaration.toLowerCase().startsWith('line-height'),
    )
    .map((declaration) => declaration.replaceAll(RegExp(r'\s*:\s*'), ':'))
    .join(';');

/// Works on a copy: the caller's document stays as it was.
String _withoutLineHeight(Document source) {
  final document = source.clone(true);
  for (final Element element in document.querySelectorAll('[style]')) {
    final style = _normalizedStyle(element);
    if (style.isEmpty) {
      element.attributes.remove('style');
    } else {
      element.attributes['style'] = style;
    }
  }
  return document.body?.innerHtml ?? '';
}

/// The output differs from the source in `line-height` declarations only.
List<String> lineHeightOnlyFailures(Document source, Document out) =>
    _withoutLineHeight(source) == _withoutLineHeight(out)
        ? const []
        : const ['changed more than line-height'];
