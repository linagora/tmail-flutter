import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import '../abstract/abstract_preferences_robot.dart';
import '../mobile/mobile_settings_robot.dart';
import 'web_preferences_robot.dart';

class WebSettingsRobot extends MobileSettingsRobot {
  WebSettingsRobot(super.$);

  @override
  AbstractPreferencesRobot get preferencesRobot => WebPreferencesRobot($);

  @override
  Future<void> openSettingsDetail(AccountMenuItem accountMenuItem) async {
    await $(
      Key('${accountMenuItem.getAliasBrowser()}_account_menu_item_tile'),
    ).tap();
  }
}
