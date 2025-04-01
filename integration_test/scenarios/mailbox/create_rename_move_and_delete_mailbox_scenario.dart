import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class CreateRenameMoveAndDeleteMailboxScenario extends BaseTestScenario {
  const CreateRenameMoveAndDeleteMailboxScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subFolderName = 'crud sub folder';
    const subFolderRenamedName = 'renamed sub folder';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appLocalizations = AppLocalizations();

    // Create sub folder
    await threadRobot.openMailbox();
    await mailboxMenuRobot.longPressMailboxWithName(
      appLocalizations.inboxMailboxDisplayName,
    );
    await mailboxMenuRobot.tapCreateNewSubFolder();
    await mailboxMenuRobot.enterNewFolderName(subFolderName);
    await mailboxMenuRobot.confirmCreateNewFolder();
    await _expectMailboxWithNameVisible(subFolderName);

    // Rename sub folder
    await threadRobot.openMailbox();
    await mailboxMenuRobot.expandMailboxWithName(
      appLocalizations.inboxMailboxDisplayName
    );
    await mailboxMenuRobot.longPressMailboxWithName(subFolderName);
    await mailboxMenuRobot.tapRenameMailbox();
    await mailboxMenuRobot.enterRenameSubFolderName(subFolderRenamedName);
    await mailboxMenuRobot.confirmRenameSubFolder();
    await _expectMailboxWithNameVisible(subFolderRenamedName);

    // Move sub folder to archive mailbox
    await mailboxMenuRobot.longPressMailboxWithName(subFolderRenamedName);
    await mailboxMenuRobot.tapMoveMailbox();
    await mailboxMenuRobot.tapMailboxWithName(appLocalizations.archiveMailboxDisplayName);
    await _expectMailboxWithNameHaveSubFolder(appLocalizations.archiveMailboxDisplayName);

    // Delete sub folder
    await mailboxMenuRobot.expandMailboxWithName(appLocalizations.archiveMailboxDisplayName);
    await mailboxMenuRobot.longPressMailboxWithName(subFolderRenamedName);
    await mailboxMenuRobot.tapDeleteMailbox();
    await mailboxMenuRobot.confirmDeleteMailbox();
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