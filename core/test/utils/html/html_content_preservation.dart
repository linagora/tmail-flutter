import 'package:html/parser.dart' show parse;

/// Share of the source words the output still shows, occurrence by
/// occurrence: a word the source repeats five times and the output shows
/// once counts as one of five kept.
double bodyWordPreservation(String source, String transformed) {
  final sourceWords = _bodyWords(source);
  if (sourceWords.isEmpty) return 1;
  final available = <String, int>{};
  for (final word in _bodyWords(transformed)) {
    available[word] = (available[word] ?? 0) + 1;
  }
  var kept = 0;
  for (final word in sourceWords) {
    final left = available[word] ?? 0;
    if (left == 0) continue;
    available[word] = left - 1;
    kept++;
  }
  return kept / sourceWords.length;
}

int bodyLinkCount(String html) =>
    parse(html).body?.querySelectorAll('a[href]').length ?? 0;

/// Every link destination in the body, sorted, so a transform that keeps the
/// number of links but rewrites where they go is caught.
List<String> bodyLinkDestinations(String html) => [
      for (final link in parse(html).body?.querySelectorAll('a[href]') ?? const [])
        link.attributes['href']!.trim(),
    ]..sort();

int bodyImageCount(String html) =>
    parse(html).body?.querySelectorAll('img').length ?? 0;

List<String> _bodyWords(String html) {
  final document = parse(html);
  document.querySelectorAll('script, style, template').forEach((node) {
    node.remove();
  });
  final body = document.body;
  if (body == null) return const [];
  return body.text
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .split(' ')
      .where((word) => word.isNotEmpty)
      .toList();
}
