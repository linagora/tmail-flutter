abstract class AbstractMailboxMenuRobot {
  Future<void> openFolderByName(String name);
  Future<void> pullToRefresh();
  Future<void> openSetting();
  Future<void> tapAddNewFolderButton();
  Future<void> enterNewFolderName(String name);
  Future<void> confirmCreateNewFolder();
}
