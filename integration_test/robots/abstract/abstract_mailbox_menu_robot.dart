import 'package:patrol/patrol.dart';

import 'abstract_mailbox_assertion_robot.dart';
import 'abstract_mailbox_empty_trash_robot.dart';
import 'abstract_mailbox_folder_robot.dart';
import 'abstract_mailbox_label_robot.dart';
import 'abstract_mailbox_navigation_robot.dart';

abstract class AbstractMailboxMenuRobot {
  PatrolFinder mailboxItemByName(String name);
  PatrolFinder mailboxItemByExactName(String name);
  PatrolFinder labelItemByName(String name);
  Future<void> pullToRefresh();
  Future<void> openSetting();
  Future<void> tapSignOut();
  Future<void> confirmSignOut();

  AbstractMailboxNavigationRobot get navigation;
  AbstractMailboxFolderRobot get folder;
  AbstractMailboxEmptyTrashRobot get emptyTrash;
  AbstractMailboxLabelRobot get label;
  AbstractMailboxAssertionRobot get assertion;
}
