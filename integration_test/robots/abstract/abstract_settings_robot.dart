import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import 'abstract_language_robot.dart';
import 'abstract_preferences_robot.dart';

abstract class AbstractSettingsRobot {
  final AbstractPreferencesRobot preferencesRobot;
  final AbstractLanguageRobot languageRobot;

  const AbstractSettingsRobot(this.preferencesRobot, this.languageRobot);

  Future<void> openSettingsDetail(AccountMenuItem accountMenuItem);
}