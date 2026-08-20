import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/clean_messages_banner.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_mailbox_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class LongPressEmptyAndRecoverTrashScenario extends BaseTestScenario {
  const LongPressEmptyAndRecoverTrashScenario(super.$, super.robots);
  
  @override
  Future<void> runTestLogic() async {
    const toEmail = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'long press trash';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appLocalizations = AppLocalizations();

    await robots.commonRobot().provisionEmail(
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
    _expectTrashCountHidden(
      appLocalizations.trashMailboxDisplayName,
    );
    final trashFolder = mailboxMenuRobot.mailboxItemByName(appLocalizations.trashMailboxDisplayName);
    await mailboxMenuRobot.navigation.longPressMailbox(trashFolder);
    await threadRobot.tapEmptyTrashAfterLongPress();
    await threadRobot.tapConfirmEmptyTrashAfterLongPress();
    _expectTrashCountHidden(
      appLocalizations.trashMailboxDisplayName,
    );
    await mailboxMenuRobot.navigation.openFolder(trashFolder);
    await _expectTrashBannerInvisible();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.navigation.longPressMailbox(trashFolder);
    await mailboxMenuRobot.tapRecoverDeletedMessages();
    await mailboxMenuRobot.tapConfirmRecoverDeletedMessages();
    await threadRobot.openMailbox();
    await mailboxMenuRobot.navigation.openFolder(
      mailboxMenuRobot.mailboxItemByName(appLocalizations.recoveredMailboxDisplayName),
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

  void _expectTrashCountHidden(String name) {
    final mailboxItem = $(SidebarMailboxItem).$(name);

    expect(mailboxItem, findsOneWidget);
    expect(mailboxItem.$(LinagoraSidebarBadge), findsNothing);
  }
}
