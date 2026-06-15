import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../../base/base_test_scenario.dart';

class TogglePreferencesScenario extends BaseTestScenario {
  TogglePreferencesScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final settingsRobot = robots.settingsRobot();
    final appLocalizations = AppLocalizations();

    await mailboxMenuRobot.openSetting();
    await settingsRobot.openSettingsDetail(AccountMenuItem.preferences);
    // Thread
    await settingsRobot.preferencesRobot.togglePreferenceOption(
      appLocalizations.thread,
    );
    await settingsRobot.preferencesRobot.expectPreferenceOption(
      appLocalizations.thread,
      switchedOn: true,
    );
    await settingsRobot.preferencesRobot.togglePreferenceOption(
      appLocalizations.thread,
    );
    await settingsRobot.preferencesRobot.expectPreferenceOption(
      appLocalizations.thread,
      switchedOn: false,
    );
    // Sender set important
    await settingsRobot.preferencesRobot.togglePreferenceOption(
      appLocalizations.senderSetImportantFlag,
    );
    await settingsRobot.preferencesRobot.expectPreferenceOption(
      appLocalizations.senderSetImportantFlag,
      switchedOn: false,
    );
    await settingsRobot.preferencesRobot.togglePreferenceOption(
      appLocalizations.senderSetImportantFlag,
    );
    await settingsRobot.preferencesRobot.expectPreferenceOption(
      appLocalizations.senderSetImportantFlag,
      switchedOn: true,
    );
  }
}
