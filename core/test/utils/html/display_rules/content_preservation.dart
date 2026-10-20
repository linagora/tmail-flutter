import 'package:html/parser.dart' show parse;

/// Share of the source words the output still shows, occurrence by
/// occurrence: a word the source repeats five times and the output shows
/// once counts as one of five kept.
double bodyWordPreservation(String source, String transformed) =>
    _keptShare(_bodyWords(source), _bodyWords(transformed));

double _keptShare(List<String> sourceWords, List<String> outputWords) {
  if (sourceWords.isEmpty) return 1;
  final available = <String, int>{};
  for (final word in outputWords) {
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

/// Share of the words of a `text/plain` [source] (raw text, not markup) that
/// the rendered HTML [transformed] still shows. The autolinker displays URLs
/// without their scheme, so schemes are ignored on both sides.
double plainTextWordPreservation(String source, String transformed) {
  String withoutScheme(String word) => word.replaceFirst(RegExp(r'^https?://'), '');
  return _keptShare(
    _words(source).map(withoutScheme).toList(),
    _bodyWords(transformed).map(withoutScheme).toList(),
  );
}

/// Every link destination in the body, sorted, so a transform that keeps the
/// number of links but rewrites where they go is caught.
List<String> bodyLinkDestinations(String html) => [
      for (final link in parse(html).body?.querySelectorAll('a[href]') ?? const [])
        link.attributes['href']!.trim(),
    ]..sort();

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
