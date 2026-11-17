import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class RecoverDeletedMessagesDescriptionScenario extends BaseTestScenario {
  const RecoverDeletedMessagesDescriptionScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appLocalizations = AppLocalizations();

    final trashFolder = mailboxMenuRobot.mailboxItemByName(appLocalizations.trashMailboxDisplayName);
    await threadRobot.openMailbox();
    await mailboxMenuRobot.navigation.longPressMailbox(trashFolder);
    await mailboxMenuRobot.tapRecoverDeletedMessages();

    await expectViewVisible($(find.textContaining(
      appLocalizations.dialogRecoverDeletedMessagesDescription('15'),
      findRichText: true,
    )));
    expect(find.textContaining('days days', findRichText: true), findsNothing);
  }
}
