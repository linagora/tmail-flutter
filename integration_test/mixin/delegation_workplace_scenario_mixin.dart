import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../robots/web/web_settings_robot.dart';
import '../robots/web/web_workplace_account_switcher_robot.dart';
import '../utils/twake_workplace_simulator.dart';

/// Shared Workplace web setup for T-08 account-switcher scenarios.
mixin DelegationWorkplaceScenarioMixin on BaseTestScenario {
  static const ownerAddress = 'alice@example.com';
  static const ownAddress = 'bob@example.com';

  WebWorkplaceAccountSwitcherRobot get workplaceSwitcher =>
      WebWorkplaceAccountSwitcherRobot($);

  @override
  Future<void> execute() async {
    // Before the seeded login opens the dashboard, which checks once whether
    // it runs inside Twake Workplace.
    simulateTwakeWorkplace();
    await super.execute();
  }

  /// Turns Delegation on in Preferences and returns to the mailbox chrome.
  Future<void> enableDelegationAndReturnToMailbox() async {
    final l10n = AppLocalizations();
    final settingsRobot = robots.settingsRobot();
    final preferencesRobot = settingsRobot.preferencesRobot;

    await robots.commonRobot().waitForMailboxReady();
    await workplaceSwitcher.assertion.expectChipHidden();

    await $(const ValueKey(UiKeys.workplaceSettingsButton)).tap();
    await $(ValueKey(ProfileSettingActionType.manageAccount.name)).tap();
    await $.pumpAndTrySettle();
    await settingsRobot.openSettingsDetail(AccountMenuItem.preferences);
    await preferencesRobot.ensureDelegationPreferenceReady();
    await preferencesRobot.togglePreferenceOption(l10n.delegation);
    await preferencesRobot.expectPreferenceOption(
      l10n.delegation,
      switchedOn: true,
    );
    await WebSettingsRobot($).closeSettings();
    await robots.commonRobot().waitForMailboxReady();
  }
}
