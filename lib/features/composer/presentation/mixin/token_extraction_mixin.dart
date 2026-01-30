/// Helper mixin to extract the full token surrounding a keyword match.
/// Example: Extracts "file-246" from text when the keyword is "file".
mixin TokenExtractionMixin {
  static final RegExp _whitespaceRegExp = RegExp(r'\s');

  String getSurroundingToken(String text, int matchStart, int matchEnd) {
    int start = matchStart;
    int end = matchEnd;

    // Expand left until whitespace
    while (start > 0) {
      if (_whitespaceRegExp.hasMatch(text[start - 1])) break;
      start--;
    }

    // Expand right until whitespace
    while (end < text.length) {
      if (_whitespaceRegExp.hasMatch(text[end])) break;
      end++;
    }

    return text.substring(start, end);
  }
}