import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../../base/base_test_scenario.dart';
import '../../../robots/abstract/abstract_settings_robot.dart';

class ToggleDelegationPreferenceScenario extends BaseTestScenario {
  ToggleDelegationPreferenceScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final settingsRobot = robots.settingsRobot();
    final preferencesRobot = settingsRobot.preferencesRobot;
    final delegation = AppLocalizations().delegation;

    await robots.mailboxMenuRobot().openSetting();
    await settingsRobot.openSettingsDetail(AccountMenuItem.preferences);
    await preferencesRobot.ensureDelegationPreferenceReady();

    await preferencesRobot.expectPreferenceOption(delegation, switchedOn: false);

    await preferencesRobot.togglePreferenceOption(delegation);
    await _reopenPreferences(settingsRobot);
    await preferencesRobot.expectPreferenceOption(delegation, switchedOn: true);

    await preferencesRobot.togglePreferenceOption(delegation);
    await _reopenPreferences(settingsRobot);
    await preferencesRobot.expectPreferenceOption(delegation, switchedOn: false);
  }

  Future<void> _reopenPreferences(AbstractSettingsRobot settingsRobot) async {
    await settingsRobot.leaveSettingsDetail();
    await settingsRobot.openSettingsDetail(AccountMenuItem.preferences);
  }
}
