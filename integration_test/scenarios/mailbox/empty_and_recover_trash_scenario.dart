import 'package:flutter_test/flutter_test.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/banner_empty_trash_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class EmptyAndRecoverTrashScenario extends BaseTestScenario {
  const EmptyAndRecoverTrashScenario(super.$);
  
  @override
  Future<void> runTestLogic() async {
    const toEmail = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'trash and recover';

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
    await mailboxMenuRobot.openFolderByName(
      appLocalizations.trashMailboxDisplayName,
      );
    await threadRobot.tapEmptyTrashBanner();
    await threadRobot.confirmEmptyTrash();
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
}