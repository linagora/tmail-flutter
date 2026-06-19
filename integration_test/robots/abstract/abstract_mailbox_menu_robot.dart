import 'package:patrol/patrol.dart';

import 'abstract_mailbox_assertion_robot.dart';
import 'abstract_mailbox_empty_trash_robot.dart';
import 'abstract_mailbox_folder_robot.dart';
import 'abstract_mailbox_navigation_robot.dart';

abstract class AbstractMailboxMenuRobot {
  PatrolFinder mailboxItemByName(String name);
  PatrolFinder mailboxItemByExactName(String name);
  Future<void> pullToRefresh();
  Future<void> openSetting();

  AbstractMailboxNavigationRobot get navigation;
  AbstractMailboxFolderRobot get folder;
  AbstractMailboxEmptyTrashRobot get emptyTrash;
  AbstractMailboxAssertionRobot get assertion;
}
