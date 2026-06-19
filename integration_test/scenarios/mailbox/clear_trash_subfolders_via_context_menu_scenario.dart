import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';

class ClearTrashSubfoldersViaContextMenuScenario extends BaseTestScenario {
  const ClearTrashSubfoldersViaContextMenuScenario(super.$, super.robots);

  static const _subfolderName = 'Trash subfolder context menu test';

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'Empty trash';
    final appLocalizations = AppLocalizations();
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final threadRobot = robots.threadRobot();

    await provisionTrashSubfolder(_subfolderName);

    await robots.commonRobot().provisionEmail([
      ProvisioningEmail(toEmail: emailUser, subject: subject, content: subject),
    ], folderLocationRole: PresentationMailbox.roleTrash);

    final trashFolder = mailboxMenuRobot.mailboxItemByName(appLocalizations.trashMailboxDisplayName);
    await threadRobot.openMailbox();
    await mailboxMenuRobot.navigation.openFolder(trashFolder);
    await threadRobot.assertion.expectTrashBannerVisible();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.navigation.longPressMailbox(mailboxMenuRobot.mailboxItemByExactName(appLocalizations.trashMailboxDisplayName));
    await mailboxMenuRobot.emptyTrash.tapEmptyTrash();
    await mailboxMenuRobot.emptyTrash.confirmEmptyTrash();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.assertion.expectSubfolderNotExist(mailboxMenuRobot.mailboxItemByName(_subfolderName));

    await mailboxMenuRobot.navigation.openFolder(trashFolder);
    await threadRobot.assertion.expectEmptyTrashThreadView();
    await threadRobot.assertion.expectTrashBannerInvisible();
  }
}
