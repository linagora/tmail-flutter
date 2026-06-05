abstract class AbstractSearchResultRobot {
  Future<void> expectSearchResultEmailListVisible();
  Future<void> expectEmailListCount(int count);
  Future<void> expectEmailListSortedBySenderAscending(List<String> listUsername);
  Future<void> expectEmailListSortedBySenderDescending(List<String> listUsername);
  Future<void> expectEmailListSortedBySubjectAscending(List<String> listUsername);
  Future<void> expectEmailListSortedBySubjectDescending(List<String> listUsername);
  Future<void> expectEmailListSortedByMostRecent();
  Future<void> expectEmailListSortedByOldest();
  Future<void> expectEmailListSortedBySizeAscending();
  Future<void> expectEmailListSortedBySizeDescending();
}
