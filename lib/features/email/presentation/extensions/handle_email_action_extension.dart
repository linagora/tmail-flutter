import 'package:core/utils/platform_info.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/email_loaded_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/list_email_in_thread_detail_info_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/presentation_email_map_extension.dart';

extension HandleEmailActionExtension on SingleEmailController {
  void markAsEmailStarSuccess(MarkAsStarEmailSuccess success) {
    final isMark = success.markStarAction == MarkStarAction.markStar;

    if (PlatformInfo.isMobile && !isThreadDetailEnabled) {
      _handleStarInMailboxContext(isMark);
    } else {
      _handleStarInThreadDetailContext(isMark);
    }

    toastManager.showMessageSuccess(success);
  }

  void _handleStarInMailboxContext(bool isMark) {
    final selectedEmail = mailboxDashBoardController.selectedEmail.value;
    if (selectedEmail == null) return;

    final emailId = selectedEmail.id!;
    final emailLoaded = currentEmailLoaded.value;

    // Update selected email
    mailboxDashBoardController.selectedEmail.value =
        isMark ? selectedEmail.star() : selectedEmail.unstar();

    // Update emailLoaded
    if (emailLoaded != null) {
      currentEmailLoaded.value = isMark
          ? emailLoaded.starById(emailId)
          : emailLoaded.unstarById(emailId);
    }

    // Update flag to list emails in dashboard
    mailboxDashBoardController.updateEmailFlagByEmailIds(
      [emailId],
      markStarAction:
          isMark ? MarkStarAction.markStar : MarkStarAction.unMarkStar,
    );
  }

  void _handleStarInThreadDetailContext(bool isMark) {
    if (threadDetailController == null) return;
    final controller = threadDetailController!;
    final currentEmailId = currentEmail?.id;
    if (currentEmailId == null) return;

    // Update list of ids
    controller.emailIdsPresentation.value = isMark
        ? controller.emailIdsPresentation.starOne(currentEmailId)
        : controller.emailIdsPresentation.unstarOne(currentEmailId);

    // Update thread detail email infos
    controller.emailsInThreadDetailInfo.value = isMark
        ? controller.emailsInThreadDetailInfo.starOne(currentEmailId)
        : controller.emailsInThreadDetailInfo.unstarOne(currentEmailId);

    // Update loaded email
    final emailLoaded = controller.currentEmailLoaded.value;
    if (emailLoaded != null) {
      controller.currentEmailLoaded.value = isMark
          ? emailLoaded.starById(currentEmailId)
          : emailLoaded.unstarById(currentEmailId);
    }

    // Update flag to emails in dashboard
    mailboxDashBoardController.updateEmailFlagByEmailIds(
      [currentEmailId],
      markStarAction:
          isMark ? MarkStarAction.markStar : MarkStarAction.unMarkStar,
    );
  }
}
