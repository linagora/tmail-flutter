import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';

class OpenInsertLinkDialogViaKeyboardShortcutScenario extends BaseTestScenario {
  const OpenInsertLinkDialogViaKeyboardShortcutScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final composerRobot = robots.composerRobot();
    final appLocalizations = AppLocalizations();

    await robots.threadRobot().openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    await composerRobot.openInsertLinkDialogViaKeyboardShortcut();

    await composerRobot.expectInsertLinkDialogVisible(appLocalizations);
  }
}
