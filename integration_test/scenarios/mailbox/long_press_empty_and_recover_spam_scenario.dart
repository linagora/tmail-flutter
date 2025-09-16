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

class LongPressEmptyAndRecoverSpamScenario extends BaseTestScenario {
  const LongPressEmptyAndRecoverSpamScenario(super.$);
  
  @override
  Future<void> runTestLogic() async {
    const toEmail = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'long press spam';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appLocalizations = AppLocalizations();

    await provisionEmail(
      [ProvisioningEmail(
        toEmail: toEmail,
        subject: subject,
        content: '',
      )],
      folderLocationRole: PresentationMailbox.roleJunk,
    );
    await $.pumpAndTrySettle(duration: const Duration(seconds: 2));
    await threadRobot.openMailbox();
    await $.pumpAndTrySettle();
    _expectSpamUnreadCountVisible(
      appLocalizations.spamMailboxDisplayName,
    );
    await mailboxMenuRobot.longPressMailboxWithName(
      appLocalizations.spamMailboxDisplayName,
    );
    await threadRobot.tapEmptySpamAfterLongPress();
    await threadRobot.confirmEmptySpam();
    await $.pumpAndTrySettle(duration: const Duration(seconds: 2));
    _expectSpamUnreadCountInvisible(
      appLocalizations.spamMailboxDisplayName,
    );
    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(
      appLocalizations.spamMailboxDisplayName,
    );
    await _expectSpamBannerInvisible();

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
  
  Future<void> _expectSpamBannerInvisible() async {
    await $(#clean_message_banner_not_visible).waitUntilExists();
    expect($(CleanMessagesBanner).visible, false);
  }

  Future<void> _expectEmailWithSubjectVisible(String subject) async {
    await expectViewVisible($(subject));
  }

  void _expectSpamUnreadCountVisible(String name) {
    expect(
      $(TrailingMailboxItemWidget).which<TrailingMailboxItemWidget>((widget) {
        final mailbox = widget.mailboxNode.item;
        return mailbox.name?.name.toLowerCase() == name.toLowerCase() &&
            mailbox.countTotalEmailsAsString.isNotEmpty;
      }),
      findsOneWidget,
    );
  }

  void _expectSpamUnreadCountInvisible(String name) {
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