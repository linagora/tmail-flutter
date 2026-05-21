import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../mobile/mobile_mailbox_menu_robot.dart';

class WebMailboxMenuRobot extends MobileMailboxMenuRobot {
  WebMailboxMenuRobot(super.$);

  @override
  Future<void> openSetting() async {
    await $(#user_avatar).tap();
    await $(AppLocalizations().manage_account).tap();
  }
}