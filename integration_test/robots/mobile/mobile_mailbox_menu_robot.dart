import '../abstract/abstract_mailbox_menu_robot.dart';
import '../mailbox_menu_robot.dart';

class MobileMailboxMenuRobot extends MailboxMenuRobot implements AbstractMailboxMenuRobot {
  MobileMailboxMenuRobot(super.$);

  @override
  Future<void> openSetting() async {
    await $(#mobile_mailbox_menu_button).tap();
    await super.openSetting();
  }
}