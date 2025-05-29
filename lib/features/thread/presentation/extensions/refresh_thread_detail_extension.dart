import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

extension RefreshThreadDetailExtension on ThreadController {
  void refreshThreadDetail(List<PresentationEmail> emailChanges) {
    if (emailChanges
        .where((email) => email.threadId != null &&
          email.threadId == mailboxDashBoardController.selectedEmail.value?.threadId)
        .isNotEmpty
    ) {
      mailboxDashBoardController
        ..dispatchEmailUIAction(RefreshThreadDetailAction())
        ..dispatchEmailUIAction(EmailUIAction());
    }
  }
}