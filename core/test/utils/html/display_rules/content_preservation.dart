import 'package:core/utils/external_link_policy.dart';
import 'package:html/parser.dart' show parse;

double bodyWordPreservation(String source, String transformed) {
  final sourceWords = _bodyWords(source);
  if (sourceWords.isEmpty) return 1;
  final outputWords = _bodyWords(transformed).toSet();
  var kept = 0;
  for (final word in sourceWords) {
    if (outputWords.contains(word)) kept++;
  }
  return kept / sourceWords.length;
}

/// Share of the words of a `text/plain` [source] (raw text, not markup) that
/// the rendered HTML [transformed] still shows. The autolinker displays URLs
/// without their scheme, so schemes are ignored on both sides.
double plainTextWordPreservation(String source, String transformed) {
  String withoutScheme(String word) => word.replaceFirst(RegExp(r'^https?://'), '');
  final sourceWords = _words(source).map(withoutScheme).toList();
  if (sourceWords.isEmpty) return 1;
  final outputWords = _bodyWords(transformed).map(withoutScheme).toSet();
  return sourceWords.where(outputWords.contains).length / sourceWords.length;
}

/// Web addresses (`http://`, `https://`, `www.`) written in a `text/plain` body:
/// the autolinker must make each one a link.
int plainTextUrlCount(String source) => RegExp(r'(?:https?://|\bwww\.)\S', caseSensitive: false).allMatches(source).length;

/// Links of the rendered [html] that open a web address.
int webLinkCount(String html) =>
    parse(html).body?.querySelectorAll('a[href^="http"]').length ?? 0;

int bodyLinkCount(String html) =>
    parse(html).body?.querySelectorAll('a[href]').length ?? 0;

/// Links of [html] the sanitizer is meant to keep: it drops a link whose
/// scheme `ExternalLinkPolicy` refuses (custom app schemes, `javascript:`...),
/// so those are not "lost" content.
int bodyKeptLinkCount(String html) =>
    parse(html)
        .body
        ?.querySelectorAll('a[href]')
        .where((link) => ExternalLinkPolicy.canKeepInContent(link.attributes['href']!))
        .length ??
    0;

List<String> _bodyWords(String html) {
  final document = parse(html);
  document.querySelectorAll('script, style, template').forEach((node) {
    node.remove();
  });
  final body = document.body;
  if (body == null) return const [];
  return _words(body.text);
}

List<String> _words(String text) => text
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim()
    .split(' ')
    .where((word) => word.isNotEmpty)
    .toList();
