import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import '../mobile/mobile_settings_robot.dart';

class WebSettingsRobot extends MobileSettingsRobot {
  WebSettingsRobot(super.$);

  @override
  Future<void> openPreferencesMenuItem() async {
    await $(
      Key(
        '${AccountMenuItem.preferences.getAliasBrowser()}_account_menu_item_tile',
      ),
    ).tap();
  }
}