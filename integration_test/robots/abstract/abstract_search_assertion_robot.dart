abstract class AbstractSearchAssertionRobot {
  Future<void> verifySearchSuggestionHighlights(String keyword);
  Future<void> expectSortBySearchFilterButtonVisible();
  // On web, showMenu popup has no container key — asserts via PopupMenuItemActionWidget.
  Future<void> expectSortOrderMenuVisible();
  // On web, EmailTileBuilder is not hit-testable — waits via waitForCondition.
  Future<void> expectSearchResultEmailListVisible();
  Future<void> expectDateTimeSearchFilterButtonVisible();
  // On web, showMenu popup has no container key — asserts via PopupMenuItemActionWidget.
  Future<void> expectDateTimeFilterContextMenuVisible();
  Future<void> expectEmailListCount(int count);
  Future<void> expectEmailListCountAtLeast(int count);
  Future<void> expectEmailListSortedByMostRecent();
  Future<void> expectEmailListSortedByOldest();
  Future<void> expectEmailListSortedBySenderAscending(List<String> usernames);
  Future<void> expectEmailListSortedBySenderDescending(List<String> usernames);
  Future<void> expectEmailListSortedBySubjectAscending(List<String> usernames);
  Future<void> expectEmailListSortedBySubjectDescending(List<String> usernames);
  Future<void> expectEmailListSortedBySizeAscending();
  Future<void> expectEmailListSortedBySizeDescending();
}
