import 'package:tmail_ui_user/features/composer/presentation/utils/local_email_draft_helper.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension RemoveLocalEmailDraftExtension on MailboxDashBoardController {
  Future<void> removeLocalEmailDraft(String composerId) async {
    if (accountId.value == null ||
        sessionCurrent == null ||
        removeLocalEmailDraftInteractor == null) {
      return;
    }

    final draftLocalId = LocalEmailDraftHelper.generateDraftLocalId(
      composerId: composerId,
      accountId: accountId.value!,
      userName: sessionCurrent!.username,
    );

    await removeLocalEmailDraftInteractor!.execute(draftLocalId);
  }
}