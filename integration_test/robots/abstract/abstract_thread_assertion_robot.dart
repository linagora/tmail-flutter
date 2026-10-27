abstract class AbstractThreadAssertionRobot {
  Future<void> expectAppGridButtonVisible();
  Future<void> expectTrashBannerVisible();
  Future<void> expectTrashBannerInvisible();
  Future<void> expectEmptyTrashThreadView();
  Future<void> expectThreadsListedOnce(List<int> threads, String subjectPrefix);
  Future<void> expectEachThreadListedOnce(
    List<int> threads,
    String subjectPrefix,
  );
  Future<void> expectListedThreadsArePrefixOf(
    List<int> threads,
    String subjectPrefix,
  );
  Future<void> expectListedThreadCountBelow(int n, String subjectPrefix);
  Future<void> expectListedThreadCountAbove(int n, String subjectPrefix);
  Future<void> expectThreadDetailOpened();
  Future<void> expectThreadDetailClosed();
}
