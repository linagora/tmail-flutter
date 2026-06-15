import 'package:tmail_ui_user/features/manage_account/presentation/menu/widgets/setting_first_level_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../abstract/abstract_preferences_robot.dart';
import '../abstract/abstract_settings_robot.dart';
import '../setting_robot.dart';
import 'mobile_preferences_robot.dart';

class MobileSettingsRobot extends SettingRobot
    implements AbstractSettingsRobot {
  MobileSettingsRobot(super.$);

  @override
  AbstractPreferencesRobot get preferencesRobot => MobilePreferencesRobot($);

  @override
  Future<void> openSettingsDetail(AccountMenuItem accountMenuItem) async {
    await $(SettingFirstLevelTileBuilder)
        .which<SettingFirstLevelTileBuilder>(
          (widget) =>
              widget.title == accountMenuItem.getName(AppLocalizations()),
        )
        .tap();
  }
}
