/// What a fixture's purpose requires of its display, checked per email by
/// the display rule tests. Sidecar `expect` values must use these names.
enum HtmlEmailExpect {
  fullDisplay,
  lazyImages,
  autoScale,
  noScale,
  quoteToggle,
  noQuoteToggle,
}

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
    this.purpose = '',
    this.contentType = htmlContentType,
    this.expect = const [],
  });

  static const htmlContentType = 'text/html';
  static const plainTextContentType = 'text/plain';

  final String name;
  final String category;

  /// The body: HTML, or the raw text when [isPlainText].
  final String html;
  final bool expectQuote;
  final bool rtl;
  final double minPreservation;
  final String source;
  final bool allowEmptyBody;
  final String purpose;
  final String contentType;
  final List<HtmlEmailExpect> expect;

  bool get isPlainText => contentType == plainTextContentType;
}
