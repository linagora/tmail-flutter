import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../robots/abstract/abstract_account_switcher_robot.dart';

/// Shared setup of the stand-alone web and the Android and iOS app account-switcher scenarios.
mixin DelegationStandaloneScenarioMixin on BaseTestScenario {
  static const ownerAddress = 'alice@example.com';
  static const ownAddress = 'bob@example.com';

  AbstractAccountSwitcherRobot get accountSwitcher =>
      robots.accountSwitcherRobot();

  /// Turns Delegation on in Preferences and returns to the mailbox chrome.
  Future<void> enableDelegationAndReturnToMailbox() async {
    final l10n = AppLocalizations();
    final settingsRobot = robots.settingsRobot();
    final preferencesRobot = settingsRobot.preferencesRobot;

    await robots.commonRobot().waitForMailboxReady();
    await accountSwitcher.assertion.expectSwitcherInactive();

    await robots.mailboxMenuRobot().openSetting();
    await settingsRobot.openSettingsDetail(AccountMenuItem.preferences);
    await preferencesRobot.ensureDelegationPreferenceReady();
    await preferencesRobot.togglePreferenceOption(l10n.delegation);
    await preferencesRobot.expectPreferenceOption(
      l10n.delegation,
      switchedOn: true,
    );
    await settingsRobot.closeSettingsFromDetail();
    await robots.commonRobot().waitForMailboxReady();
  }
}
