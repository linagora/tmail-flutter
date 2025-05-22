import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension MarkCollapsedEmailReadSuccess on ThreadDetailController {
  void markCollapsedEmailReadSuccess(MarkAsEmailReadSuccess success) {
    if (success.readActions == ReadActions.markAsRead) {
      emailIdsPresentation[success.emailId]
        ?.keywords
        ?[KeyWordIdentifier.emailSeen] = true;
    } else {
      emailIdsPresentation[success.emailId]
        ?.keywords?.remove(KeyWordIdentifier.emailSeen);
    }
    mailboxDashBoardController.updateEmailFlagByEmailIds(
      [success.emailId],
      readAction: success.readActions,
    );

    if (success.readActions == ReadActions.markAsRead) return;
    if (emailIdsPresentation.length == 1) {
      closeThreadDetailAction(currentContext);
    } else {
      emailIdsPresentation[success.emailId] = emailIdsPresentation
        [success.emailId]
        ?.copyWith(
          emailInThreadStatus: EmailInThreadStatus.collapsed,
        );
    }
  }
}