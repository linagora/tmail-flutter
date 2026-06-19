import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/default_mobile_app_bar_thread_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class CreateAndHideSubFolderScenario extends BaseTestScenario {
  const CreateAndHideSubFolderScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const subFolderName = 'hidden sub folder';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appLocalizations = AppLocalizations();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.navigation.longPressMailbox(
      mailboxMenuRobot.mailboxItemByName(appLocalizations.inboxMailboxDisplayName),
    );
    await mailboxMenuRobot.folder.tapCreateNewSubFolder();
    await mailboxMenuRobot.folder.enterNewFolderName(subFolderName);
    await mailboxMenuRobot.folder.confirmCreateNewFolder();
    await _expectMailboxWithNameVisible(subFolderName);

    await threadRobot.openMailbox();
    await mailboxMenuRobot.navigation.expandMailbox(
      mailboxMenuRobot.mailboxItemByName(appLocalizations.inboxMailboxDisplayName),
    );
    await mailboxMenuRobot.navigation.longPressMailbox(mailboxMenuRobot.mailboxItemByName(subFolderName));
    await mailboxMenuRobot.folder.tapHideMailbox();
    await _expectMailboxWithNameHaveNoChildren(
      appLocalizations.inboxMailboxDisplayName
    );
    await mailboxMenuRobot.closeMenu();
    await _expectMailboxWithNameVisible(
      appLocalizations.inboxMailboxDisplayName
    );
  }

  Future<void> _expectMailboxWithNameVisible(String name) async {
    await expectViewVisible(
      $(DefaultMobileAppBarThreadWidget).$(name)
    );
  }

  Future<void> _expectMailboxWithNameHaveNoChildren(String name) async {
    await expectViewVisible(
      $(MailboxItemWidget)
        .which<MailboxItemWidget>((widget) {
          return widget.mailboxNode.item.name?.name.toLowerCase() ==
            name.toLowerCase() && !widget.mailboxNode.hasChildren();
        })
    );
  }
}
