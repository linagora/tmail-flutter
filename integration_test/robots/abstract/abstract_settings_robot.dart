import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import 'abstract_preferences_robot.dart';

abstract class AbstractSettingsRobot {
  final AbstractPreferencesRobot preferencesRobot;

  const AbstractSettingsRobot(this.preferencesRobot);

  Future<void> openSettingsDetail(AccountMenuItem accountMenuItem);
}