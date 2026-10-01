import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/destination_picker_robot.dart';
import '../../robots/setting_robot.dart';

class RuleMoveActionExcludesOutgoingFoldersScenario extends BaseTestScenario {
  const RuleMoveActionExcludesOutgoingFoldersScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final appLocalizations = AppLocalizations();

    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final settingRobot = SettingRobot($);
    final emailRulesSettingRobot = robots.emailRulesSettingRobot();
    final rulesFilterCreatorRobot = robots.rulesFilterCreatorRobot();
    final destinationPickerRobot = DestinationPickerRobot($);

    await mailboxMenuRobot.openSetting();

    await settingRobot.openEmailRulesMenuItem();

    await emailRulesSettingRobot.openRuleCreator(
      addRuleLabel: appLocalizations.addARule,
      createFirstRuleLabel: appLocalizations.createMyFirstRule,
    );

    await rulesFilterCreatorRobot.expectCreatorViewVisible();

    await rulesFilterCreatorRobot.selectEmptyActionSlot(
      appLocalizations.moveMessage,
      appLocalizations.selectAction,
    );

    await rulesFilterCreatorRobot.openMoveMessageFolderPicker();

    await _expectInboxOffered(destinationPickerRobot, appLocalizations);

    _expectOutgoingFoldersNotOffered(destinationPickerRobot, appLocalizations);
  }

  Future<void> _expectInboxOffered(
    DestinationPickerRobot destinationPickerRobot,
    AppLocalizations appLocalizations,
  ) async {
    await destinationPickerRobot.assertion.expectFolderVisible(
      destinationPickerRobot.folderByName(appLocalizations.inboxMailboxDisplayName),
    );
  }

  void _expectOutgoingFoldersNotOffered(
    DestinationPickerRobot destinationPickerRobot,
    AppLocalizations appLocalizations,
  ) {
    for (final folderName in [
      appLocalizations.outboxMailboxDisplayName,
      appLocalizations.draftsMailboxDisplayName,
      appLocalizations.templatesMailboxDisplayName,
    ]) {
      destinationPickerRobot.assertion.expectFolderAbsent(
        destinationPickerRobot.folderByName(folderName),
      );
    }
  }
}
