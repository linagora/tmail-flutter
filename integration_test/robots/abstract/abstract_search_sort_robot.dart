abstract class AbstractSearchSortRobot {
  Future<void> openSortOrderMenu();
  Future<void> expectSortOrderMenuVisible();
  Future<void> selectSortOrder(String sortOrderName);
}
