abstract class AbstractSearchRobot {
  Future<void> enterKeyword(String keyword);
  Future<void> verifySearchSuggestionHighlights(String keyword);
  Future<void> tapOnShowAllResultsText();
  Future<void> scrollToEndListSearchFilter();
}
