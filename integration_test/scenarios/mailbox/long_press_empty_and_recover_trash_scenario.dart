import 'package:flutter_test/flutter_test.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/clean_messages_banner.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/trailing_mailbox_item_widget.dart';
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
      folderLocationRole: PresentationMailbox.roleTrash,
    );
    await $.pumpAndTrySettle(duration: const Duration(seconds: 2));
    await threadRobot.openMailbox();
    await $.pumpAndTrySettle();
    _expectTrashUnreadCountVisible(
      appLocalizations.trashMailboxDisplayName,
    );
    await mailboxMenuRobot.longPressMailboxWithName(
      appLocalizations.trashMailboxDisplayName,
    );
    await threadRobot.tapEmptyTrashAfterLongPress();
    await threadRobot.tapConfirmEmptyTrashAfterLongPress();
    _expectTrashUnreadCountInvisible(
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
    await $(#clean_message_banner_not_visible).waitUntilExists();
    expect($(CleanMessagesBanner).visible, false);
  }

  Future<void> _expectEmailWithSubjectVisible(String subject) async {
    await $.scrollUntilVisible(finder: $(subject));
    await expectViewVisible($(subject));
  }

  void _expectTrashUnreadCountVisible(String name) {
    expect(
      $(TrailingMailboxItemWidget).which<TrailingMailboxItemWidget>((widget) {
        final mailbox = widget.mailboxNode.item;
        return mailbox.name?.name.toLowerCase() == name.toLowerCase() &&
            mailbox.countTotalEmailsAsString.isNotEmpty;
      }),
      findsOneWidget,
    );
  }

  void _expectTrashUnreadCountInvisible(String name) {
    expect(
      $(TrailingMailboxItemWidget).which<TrailingMailboxItemWidget>((widget) {
        final mailbox = widget.mailboxNode.item;
        return mailbox.name?.name.toLowerCase() == name.toLowerCase() &&
            mailbox.countTotalEmailsAsString.isNotEmpty;
      }),
      findsNothing,
    );
  }
}