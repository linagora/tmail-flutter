import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension MarkCollapsedEmailUnreadSuccess on ThreadDetailController {
  void markCollapsedEmailUnreadSuccess(MarkAsEmailReadSuccess success) {
    mailboxDashBoardController.updateEmailFlagByEmailIds(
      [success.emailId],
      readAction: ReadActions.markAsUnread,
    );
    closeThreadDetailAction(currentContext);
  }
}