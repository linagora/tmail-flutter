abstract class AbstractSearchRobot {
  Future<void> enterKeyword(String keyword);
  Future<void> verifySearchSuggestionHighlights(String keyword);
  Future<void> tapOnShowAllResultsText();
  Future<void> scrollToEndListSearchFilter();
  Future<void> expectSuggestionListVisible();
  Future<void> openSortOrderMenu();
  Future<void> expectSortOrderMenuVisible();
  Future<void> selectSortOrder(String sortOrderName);
  Future<void> expectSearchResultEmailListVisible();
}
