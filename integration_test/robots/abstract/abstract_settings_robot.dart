import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import 'abstract_delegation_settings_robot.dart';
import 'abstract_language_robot.dart';
import 'abstract_preferences_robot.dart';

abstract class AbstractSettingsRobot {
  final AbstractPreferencesRobot preferencesRobot;
  final AbstractLanguageRobot languageRobot;

  const AbstractSettingsRobot(this.preferencesRobot, this.languageRobot);

  AbstractDelegationSettingsRobot get delegationRobot;

  Future<void> openSettingsDetail(AccountMenuItem accountMenuItem);

  Future<void> leaveSettingsDetail();

  /// Leave Settings back to the mailbox dashboard.
  Future<void> closeSettings();

  /// Leave Settings back to the mailbox dashboard from an open detail.
  Future<void> closeSettingsFromDetail();
}