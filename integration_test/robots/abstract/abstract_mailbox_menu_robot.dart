abstract class AbstractMailboxMenuRobot {
  Future<void> openFolderByName(String name);
  Future<void> pullToRefresh();
  Future<void> openSetting();
  Future<void> expectSubfolderNotExist(String subfolderName);
  Future<void> tapEmptyTrashInContextMenu();
  Future<void> confirmEmptyTrashInContextMenu();
  Future<void> openTrashContextMenu(String trashFolderName);
}
