import 'package:flutter_test/flutter_test.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/trailing_mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/banner_empty_trash_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class LongPressEmptyAndRecoverTrashScenario extends BaseTestScenario {
  const LongPressEmptyAndRecoverTrashScenario(super.$);
  
  @override
  Future<void> runTestLogic() async {
    const toEmail = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'long press trash';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appLocalizations = AppLocalizations();

    await provisionEmail(
      [ProvisioningEmail(
        toEmail: toEmail,
        subject: subject,
        content: '',
      )],
      sentLocation: PresentationMailbox.roleTrash,
    );

    await threadRobot.openMailbox();
    await _expectMailboxWithNameHaveCountVisible(
      appLocalizations.trashMailboxDisplayName,
    );
    await mailboxMenuRobot.longPressMailboxWithName(
      appLocalizations.trashMailboxDisplayName,
    );
    await threadRobot.tapEmptyTrashAfterLongPress();
    await threadRobot.tapConfirmEmptyTrashAfterLongPress();
    _expectMailboxWithNameHaveCountInvisible(
      appLocalizations.trashMailboxDisplayName,
    );
    await mailboxMenuRobot.openFolderByName(
      appLocalizations.trashMailboxDisplayName,
    );
    await _expectTrashBannerInvisible();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.longPressMailboxWithName(
      appLocalizations.trashMailboxDisplayName,
    );
    await mailboxMenuRobot.tapRecoverDeletedMessages();
    await mailboxMenuRobot.tapConfirmRecoverDeletedMessages();
    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(
      appLocalizations.recoveredMailboxDisplayName,
    );
    await _expectEmailWithSubjectVisible(subject);
  }
  
  Future<void> _expectTrashBannerInvisible() async {
    await $(#trash_banner_not_visible).waitUntilExists();
    expect($(BannerEmptyTrashWidget).visible, false);
  }

  Future<void> _expectEmailWithSubjectVisible(String subject) async {
    await expectViewVisible($(subject));
  }
  
  Future<void> _expectMailboxWithNameHaveCountVisible(String name) async {
    await expectViewVisible(
      $(TrailingMailboxItemWidget)
        .which<TrailingMailboxItemWidget>((widget) {
          return widget.mailboxNode.item.name?.name.toLowerCase() == name.toLowerCase();
        })
    );
  }
  
  void _expectMailboxWithNameHaveCountInvisible(String name) {
    expect(
      $(TrailingMailboxItemWidget)
        .which<TrailingMailboxItemWidget>((widget) {
          return widget.mailboxNode.item.name?.name.toLowerCase() == name.toLowerCase();
        })
        .visible,
      false,
    );
  }
}