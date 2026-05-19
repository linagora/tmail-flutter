import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';

class OpenInsertLinkDialogViaKeyboardShortcutScenario extends BaseTestScenario {
  const OpenInsertLinkDialogViaKeyboardShortcutScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final composerRobot = robots.composerRobot();
    final appLocalizations = AppLocalizations();

    await timedStep('open_composer', () => robots.threadRobot().openComposer());
    await timedStep('expect_composer', () => composerRobot.expectComposerViewVisible());
    await timedStep('grant_contact_permission', () => composerRobot.grantContactPermission());
    await timedStep('open_insert_link_dialog', () => composerRobot.openInsertLinkDialogViaKeyboardShortcut());
    await timedStep('expect_insert_link_dialog', () => composerRobot.expectInsertLinkDialogVisible(appLocalizations));
  }
}
