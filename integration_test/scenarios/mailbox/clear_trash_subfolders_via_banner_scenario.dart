import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';

class ClearTrashSubfoldersViaBannerScenario extends BaseTestScenario {
  const ClearTrashSubfoldersViaBannerScenario(super.$, super.robots);

  static const _subfolderName = 'Trash subfolder banner test';

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

    await threadRobot.emptyTrash.tapEmptyTrashBanner();
    await threadRobot.emptyTrash.confirmEmptyTrash();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.assertion.expectSubfolderNotExist(mailboxMenuRobot.mailboxItemByName(_subfolderName));

    await mailboxMenuRobot.navigation.openFolder(trashFolder);
    await threadRobot.assertion.expectEmptyTrashThreadView();
    await threadRobot.assertion.expectTrashBannerInvisible();
  }
}
