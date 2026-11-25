import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/thread_robot.dart';
import '../../robots/web/web_mailbox_menu_robot.dart';

class TouchLongPressFolderOnMobileWebScenario extends BaseTestScenario {
  const TouchLongPressFolderOnMobileWebScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final appLocalizations = AppLocalizations();
    final mailboxMenuRobot = robots.mailboxMenuRobot();

    await robots.commonRobot().waitForMailboxReady();
    await robots.searchRobot().viewport.resizeToMobileViewport();
    // Base ThreadRobot taps the phone app bar menu button; the web one is a no-op.
    await ThreadRobot($).openMailbox();

    await WebMailboxNavigationRobot($).touchLongPressMailbox(
      mailboxMenuRobot.mailboxItemByName(appLocalizations.inboxMailboxDisplayName),
    );

    await expectViewVisible(
      $(BottomSheet).$(appLocalizations.newSubfolder),
    );
  }
}
