/// Interface for defining custom keyword validation logic.
abstract class KeywordFilter {
  /// Returns `true` to keep the keyword, `false` to reject it.
  bool isValid(String fullText, Match match);
}