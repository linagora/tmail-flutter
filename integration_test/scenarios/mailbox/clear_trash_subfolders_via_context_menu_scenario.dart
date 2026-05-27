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

    await provisionEmail(
      [
        ProvisioningEmail(
          toEmail: emailUser,
          subject: subject,
          content: subject,
        ),
      ],
      folderLocationRole: PresentationMailbox.roleTrash,
    );

    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(
      appLocalizations.trashMailboxDisplayName,
    );
    await threadRobot.expectTrashBannerVisible();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.openTrashContextMenu(
      appLocalizations.trashMailboxDisplayName,
    );
    await mailboxMenuRobot.tapEmptyTrashInContextMenu();
    await mailboxMenuRobot.confirmEmptyTrashInContextMenu();

    await mailboxMenuRobot.expectSubfolderNotExist(_subfolderName);

    await mailboxMenuRobot.openFolderByName(
      appLocalizations.trashMailboxDisplayName,
    );
    await threadRobot.expectEmptyTrashThreadView();
    await threadRobot.expectTrashBannerInvisible();
  }
}
