abstract class AbstractSearchInputRobot {
  Future<void> enterKeyword(String keyword);
  Future<void> verifySearchSuggestionHighlights(String keyword);
  Future<void> tapOnShowAllResultsText();
  Future<void> expectSuggestionListVisible();
  Future<void> scrollToEndListSearchFilter();
}
