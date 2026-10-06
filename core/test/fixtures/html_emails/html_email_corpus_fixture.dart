class HtmlEmailCorpusFixture {
  const HtmlEmailCorpusFixture({
    required this.name,
    required this.category,
    required this.html,
    this.expectQuote = false,
    this.rtl = false,
    this.minPreservation = 0.95,
    this.source = '',
    this.allowEmptyBody = false,
  });

  final String name;
  final String category;
  final String html;
  final bool expectQuote;
  final bool rtl;
  final double minPreservation;
  final String source;
  final bool allowEmptyBody;
}
