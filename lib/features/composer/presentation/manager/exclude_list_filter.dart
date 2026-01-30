import 'package:tmail_ui_user/features/composer/presentation/manager/keyword_filter.dart';

/// Implementation of Exclude List Filter.
/// Optimized for memory usage by avoiding unnecessary String allocations.
class ExcludeListFilter implements KeywordFilter {
  final Set<String> _excludes;

  /// Constructor takes a List for convenience, but converts to Set for O(1) lookup.
  ExcludeListFilter(List<String> rawExcludes)
      : _excludes = rawExcludes.map((e) => e.toLowerCase()).toSet();

  /// Static RegExp to check for whitespace.
  /// Using a static instance avoids re-compilation in loops.
  static final RegExp _whitespaceRegExp = RegExp(r'\s');

  @override
  bool isValid(String fullText, Match match) {
    if (_excludes.isEmpty) return true;

    // Extract the full token surrounding the match
    final token = _getSurroundingToken(fullText, match.start, match.end);
    final lowerToken = token.toLowerCase();

    // Exact match with the token (e.g., "file-246")
    if (_excludes.contains(lowerToken)) return false;

    // Match with trailing punctuation removed (e.g., "file246." -> "file246")
    final cleanToken = lowerToken.replaceAll(RegExp(r'[^\w\s]+$'), '');
    if (_excludes.contains(cleanToken)) return false;

    return true;
  }

  /// Extracts the surrounding token without creating garbage strings.
  /// Instead of using .trim() inside a loop (which allocates memory),
  /// we check characters directly.
  String _getSurroundingToken(String text, int matchStart, int matchEnd) {
    int start = matchStart;
    int end = matchEnd;

    // Expand to the left until whitespace or start of string
    while (start > 0) {
      // Check the character before the current start index
      if (_whitespaceRegExp.hasMatch(text[start - 1])) break;
      start--;
    }

    // Expand to the right until whitespace or end of string
    while (end < text.length) {
      if (_whitespaceRegExp.hasMatch(text[end])) break;
      end++;
    }
    return text.substring(start, end);
  }
}
