import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
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
    _autoSyncStarToSelectedEmailOnMemory(
      markStarAction: success.markStarAction,
      emailId: success.emailId,
      starKeyword: KeyWordIdentifier.emailFlagged,
    );

    toastManager.showMessageSuccess(success);
  }

  void _autoSyncStarToSelectedEmailOnMemory({
    required MarkStarAction markStarAction,
    required EmailId emailId,
    required KeyWordIdentifier starKeyword,
  }) {
    _updateStarInEmailOnMemory(
      emailId: emailId,
      starKeyword: starKeyword,
      markStarAction: markStarAction,
      isMobileThreadDisabled: PlatformInfo.isMobile && !isThreadDetailEnabled,
    );
  }

  void _updateStarInEmailOnMemory({
    required MarkStarAction markStarAction,
    required EmailId emailId,
    required KeyWordIdentifier starKeyword,
    required bool isMobileThreadDisabled,
  }) {
    final remove = markStarAction == MarkStarAction.unMarkStar;

    if (isMobileThreadDisabled) {
      final selectedEmail = mailboxDashBoardController.selectedEmail.value;
      if (selectedEmail?.id == emailId) {
        mailboxDashBoardController.selectedEmail.value =
            selectedEmail?.toggleKeyword(keyword: starKeyword, remove: remove);
      }
    } else {
      final controller = threadDetailController;
      if (controller != null) {
        controller.emailIdsPresentation.value =
            controller.emailIdsPresentation.toggleEmailKeywordById(
          emailId: emailId,
          keyword: starKeyword,
          remove: remove,
        );

        controller.emailsInThreadDetailInfo.value =
            controller.emailsInThreadDetailInfo.toggleEmailKeywordById(
          emailId: emailId,
          keyword: starKeyword,
          remove: remove,
        );
      }
    }

    final emailLoaded = currentEmailLoaded.value;
    if (emailLoaded != null && emailLoaded.emailCurrent?.id == emailId) {
      currentEmailLoaded.value = emailLoaded.toggleEmailKeyword(
        emailId: emailId,
        keyword: starKeyword,
        remove: remove,
      );
    }

    mailboxDashBoardController.updateEmailFlagByEmailIds(
      [emailId],
      markStarAction: markStarAction,
    );
  }
}
