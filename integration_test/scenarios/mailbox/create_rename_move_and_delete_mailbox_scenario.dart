import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class CreateRenameMoveAndDeleteMailboxScenario extends BaseTestScenario {
  const CreateRenameMoveAndDeleteMailboxScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const subFolderName = 'crud sub folder';
    const subFolderRenamedName = 'renamed sub folder';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appLocalizations = AppLocalizations();

    // Create sub folder
    await threadRobot.openMailbox();
    await mailboxMenuRobot.navigation.longPressMailbox(
      mailboxMenuRobot.mailboxItemByName(appLocalizations.inboxMailboxDisplayName),
    );
    await mailboxMenuRobot.folder.tapCreateNewSubFolder();
    await mailboxMenuRobot.folder.enterNewFolderName(subFolderName);
    await mailboxMenuRobot.folder.confirmCreateNewFolder();
    await _expectMailboxWithNameVisible(subFolderName);

    // Rename sub folder
    await threadRobot.openMailbox();
    await mailboxMenuRobot.navigation.expandMailbox(
      mailboxMenuRobot.mailboxItemByName(appLocalizations.inboxMailboxDisplayName),
    );
    await mailboxMenuRobot.navigation.longPressMailbox(mailboxMenuRobot.mailboxItemByName(subFolderName));
    await mailboxMenuRobot.folder.tapRenameMailbox();
    await mailboxMenuRobot.folder.enterRenameSubFolderName(subFolderRenamedName);
    await mailboxMenuRobot.folder.confirmRenameSubFolder();
    await _expectMailboxWithNameVisible(subFolderRenamedName);

    // Move sub folder to archive mailbox
    await mailboxMenuRobot.navigation.longPressMailbox(mailboxMenuRobot.mailboxItemByName(subFolderRenamedName));
    await mailboxMenuRobot.folder.tapMoveMailbox();
    await mailboxMenuRobot.navigation.tapMailbox(mailboxMenuRobot.mailboxItemByName(appLocalizations.archiveMailboxDisplayName));
    await _expectMailboxWithNameHaveSubFolder(appLocalizations.archiveMailboxDisplayName);

    // Delete sub folder
    await mailboxMenuRobot.navigation.expandMailbox(mailboxMenuRobot.mailboxItemByName(appLocalizations.archiveMailboxDisplayName));
    await mailboxMenuRobot.navigation.longPressMailbox(mailboxMenuRobot.mailboxItemByName(subFolderRenamedName));
    await mailboxMenuRobot.folder.tapDeleteMailbox();
    await mailboxMenuRobot.folder.confirmDeleteMailbox();
    await _expectMailboxWithNameNotHaveSubFolder(appLocalizations.archiveMailboxDisplayName);
  }

  Future<void> _expectMailboxWithNameVisible(String name) async {
    await expectViewVisible($(name));
  }

  Future<void> _expectMailboxWithNameHaveSubFolder(String name) async {
    await expectViewVisible(
      $(MailboxItemWidget).which<MailboxItemWidget>((widget) {
        return widget.mailboxNode.item.name?.name.toLowerCase() == name.toLowerCase()
          && widget.mailboxNode.hasChildren();
      })
    );
  }
  
  Future<void> _expectMailboxWithNameNotHaveSubFolder(String name) async {
    await expectViewVisible(
      $(MailboxItemWidget).which<MailboxItemWidget>((widget) {
        return widget.mailboxNode.item.name?.name.toLowerCase() == name.toLowerCase()
          && !widget.mailboxNode.hasChildren();
      })
    );
  }
}