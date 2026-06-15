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
    await settingsRobot.openPreferencesMenuItem();
    // Thread
    await settingsRobot.togglePreference(appLocalizations.thread);
    await settingsRobot.expectPreference(appLocalizations.thread, switchedOn: true);
    await settingsRobot.togglePreference(appLocalizations.thread);
    await settingsRobot.expectPreference(appLocalizations.thread, switchedOn: false);
    // Sender set important
    await settingsRobot.togglePreference(
      appLocalizations.senderSetImportantFlag,
    );
    await settingsRobot.expectPreference(
      appLocalizations.senderSetImportantFlag,
      switchedOn: false,
    );
    await settingsRobot.togglePreference(
      appLocalizations.senderSetImportantFlag,
    );
    await settingsRobot.expectPreference(
      appLocalizations.senderSetImportantFlag,
      switchedOn: true,
    );
  }
}
