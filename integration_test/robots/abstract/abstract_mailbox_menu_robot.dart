import 'package:patrol/patrol.dart';

import 'abstract_mailbox_assertion_robot.dart';
import 'abstract_mailbox_empty_trash_robot.dart';
import 'abstract_mailbox_folder_robot.dart';
import 'abstract_mailbox_label_robot.dart';
import 'abstract_mailbox_navigation_robot.dart';
import 'abstract_workplace_profile_menu_robot.dart';

abstract class AbstractMailboxMenuRobot {
  PatrolFinder mailboxItemByName(String name);
  PatrolFinder mailboxItemByExactName(String name);
  PatrolFinder labelItemByName(String name);
  Future<void> pullToRefresh();
  Future<void> openSetting();

  AbstractMailboxNavigationRobot get navigation;
  AbstractMailboxFolderRobot get folder;
  AbstractMailboxEmptyTrashRobot get emptyTrash;
  AbstractMailboxLabelRobot get label;
  AbstractMailboxAssertionRobot get assertion;

  /// Web only: the profile menu while embedded in Twake Workplace.
  AbstractWorkplaceProfileMenuRobot? get workplaceProfileMenu;
}
