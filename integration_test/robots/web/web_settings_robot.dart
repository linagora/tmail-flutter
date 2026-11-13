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

  @override
  Future<void> leaveSettingsDetail() async {
    // Web: the menu stays on screen, so leaving a detail means opening another one.
    await openSettingsDetail(AccountMenuItem.languageAndRegion);
  }

  /// Web desktop (incl. Workplace) uses the sidebar Back, not the mobile close.
  @override
  Future<void> closeSettings() async {
    await $(#back_to_dashboard_button).tap();
  }

  /// The sidebar Back stays on screen while a detail is open.
  @override
  Future<void> closeSettingsFromDetail() => closeSettings();
}
