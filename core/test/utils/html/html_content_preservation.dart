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

int bodyLinkCount(String html) =>
    parse(html).body?.querySelectorAll('a[href]').length ?? 0;

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
