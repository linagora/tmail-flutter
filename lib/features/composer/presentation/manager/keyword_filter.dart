/// Common interface for all keyword filters.
abstract class KeywordFilter {
  /// Returns `true` if the keyword is valid.
  /// Returns `false` if the keyword should be rejected.
  bool isValid(String fullText, Match match);
}