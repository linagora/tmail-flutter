import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';

class RecoverDeletedMessagesDescriptionWebScenario extends BaseTestScenario {
  const RecoverDeletedMessagesDescriptionWebScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final appLocalizations = AppLocalizations();

    final trashFolder = mailboxMenuRobot.mailboxItemByName(appLocalizations.trashMailboxDisplayName);
    await mailboxMenuRobot.navigation.openFolder(trashFolder);

    final recoverButton = $(const Key('recover_deleted_messages_button'));
    await recoverButton.waitUntilVisible();
    await recoverButton.tap();
    await $.pumpAndSettle();

    await expectViewVisible($(find.textContaining(
      appLocalizations.dialogRecoverDeletedMessagesDescription('15'),
      findRichText: true,
    )));
    expect(find.textContaining('days days', findRichText: true), findsNothing);
  }
}
