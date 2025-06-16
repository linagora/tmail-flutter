import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleEmailMovedAction on ThreadDetailController {
  void handleEmailMovedAction(EmailMovedAction action) {
    if (emailIdsPresentation[action.emailId] == null) return;

    emailIdsPresentation[action.emailId] = emailIdsPresentation[action.emailId]
        ?.copyWith(mailboxIds: {action.targetMailboxId: true});
  }
}