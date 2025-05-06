
import 'package:flutter_test/flutter_test.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/label_mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class EmptyTrashScenario extends BaseTestScenario {

  const EmptyTrashScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'Empty trash';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appLocalizations = AppLocalizations();

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
    await $.pumpAndSettle();

    await threadRobot.openMailbox();
    await _expectMailboxViewVisible();
    await _expectFolderVisible(appLocalizations.trashMailboxDisplayName);

    await mailboxMenuRobot.openFolderByName(
      appLocalizations.trashMailboxDisplayName,
    );
    await $.pumpAndSettle();
    await _expectEmptyTrashBannerVisible();
    await _expectEmailWithSubjectVisible(subject);

    await threadRobot.tapEmptyTrashBanner();
    await _expectEmptyTrashConfirmDialogVisible(appLocalizations);
    await threadRobot.tapDeleteAllButtonOnEmptyTrashConfirmDialog(
      appLocalizations,
    );
    await $.pumpAndSettle(duration: const Duration(seconds: 3));
    await _expectEmptyViewVisible();
  }

  Future<void> _expectMailboxViewVisible() => expectViewVisible($(MailboxView));

  Future<void> _expectFolderVisible(String folderName) {
    return expectViewVisible($(MailboxItemWidget)
        .$(LabelMailboxItemWidget)
        .$(find.text(folderName)));
  }

  Future<void> _expectEmptyTrashBannerVisible() =>
      expectViewVisible($(#empty_trash_banner));

  Future<void> _expectEmailWithSubjectVisible(String subject) =>
      expectViewVisible($(subject));

  Future<void> _expectEmptyTrashConfirmDialogVisible(
    AppLocalizations appLocalizations,
  ) => expectViewVisible($(appLocalizations.empty_trash_dialog_message));

  Future<void> _expectEmptyViewVisible() =>
      expectViewVisible($(#empty_thread_view));
}