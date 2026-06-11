import 'abstract_mailbox_assertion_robot.dart';
import 'abstract_mailbox_menu_folder_robot.dart';

abstract class AbstractMailboxMenuRobot
    implements AbstractMailboxMenuFolderRobot, AbstractMailboxAssertionRobot {
  Future<void> openFolderByName(String name);
  Future<void> pullToRefresh();
  Future<void> openSetting();
}
