/// Helper mixin to extract the full token surrounding a keyword match.
/// Example: Extracts "file-246" from text when the keyword is "file".
mixin TokenExtractionMixin {
  static final RegExp _whitespaceRegExp = RegExp(r'\s');

  int _expandLeft(String text, int start) {
    while (start > 0 && !_whitespaceRegExp.hasMatch(text[start - 1])) {
      start--;
    }
    return start;
  }

  int _expandRight(String text, int end) {
    while (end < text.length && !_whitespaceRegExp.hasMatch(text[end])) {
      end++;
    }
    return end;
  }

  String getSurroundingToken(String text, int matchStart, int matchEnd) {
    final start = _expandLeft(text, matchStart);
    final end = _expandRight(text, matchEnd);
    return text.substring(start, end);
  }
}