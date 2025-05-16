import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/get_mailbox_contain_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/load_more_thread_detail_emails.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/thread_detail_on_email_action_click.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/thread_detail_open_email_address_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/toggle_thread_detail_collape_expand.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_collapsed_email.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_load_more_circle.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension GetThreadDetailEmailViews on ThreadDetailController {
  List<Widget> getThreadDetailEmailViews() {
    int? firstEmailNotLoadedIndex;
    if (emailsNotLoadedCount > 0) {
      firstEmailNotLoadedIndex = emailIds.indexOf(
        emailIdsPresentation.entries.firstWhereOrNull(
          (entry) => entry.value == null
        )?.key
      );
    }

    return emailIdsPresentation.entries.map((entry) {
      final emailId = entry.key;
      final presentationEmail = entry.value;
      if (presentationEmail == null) {
        if (emailIds.indexOf(emailId) != firstEmailNotLoadedIndex) {
          return const SizedBox.shrink();
        }

        return ThreadDetailLoadMoreCircle(
          count: emailsNotLoadedCount,
          onTap: loadMoreThreadDetailEmails,
          imagePaths: imagePaths,
          isLoading: loadingThreadDetail,
        );
      }

      if (presentationEmail.emailInThreadStatus == null) {
        return const SizedBox.shrink();
      }

      final isFirstEmailInThreadDetail = emailIds.indexOf(emailId) == 0;
      final isLastEmailInThreadDetail = emailIds.indexOf(emailId) ==
        emailIds.length - 1;

      if (presentationEmail.emailInThreadStatus == EmailInThreadStatus.collapsed) {
        return ThreadDetailCollapsedEmail(
          presentationEmail: presentationEmail.copyWith(
            subject: isFirstEmailInThreadDetail
              ? emailIdsPresentation.values.last?.subject
              : null
          ),
          showSubject: isFirstEmailInThreadDetail,
          imagePaths: imagePaths,
          responsiveUtils: responsiveUtils,
          mailboxContain: presentationEmail.mailboxContain,
          emailLoaded: null,
          onEmailActionClick: threadDetailOnEmailActionClick,
          onMoreActionClick: (presentationEmail, position) => emailActionReactor.handleMoreEmailAction(
            mailboxContain: mailboxDashBoardController.getMailboxContain(presentationEmail),
            presentationEmail: presentationEmail,
            position: position,
            emailLoaded: getBinding<SingleEmailController>(
              tag: presentationEmail.id?.id.value,
            )?.currentEmailLoaded.value,
            responsiveUtils: responsiveUtils,
            imagePaths: imagePaths,
            username: session?.username,
            handleEmailAction: threadDetailOnEmailActionClick,
            additionalActions: [
              EmailActionType.forward,
              EmailActionType.replyAll,
              EmailActionType.replyToList,
            ],
          ),
          openEmailAddressDetailAction: (_, emailAddress) {
            openEmailAddressDetailAction(emailAddress);
          },
          onToggleThreadDetailCollapseExpand: () {
            toggleThreadDetailCollapeExpand(presentationEmail);
          },
        );
      }

      return EmailView(
        key: ValueKey(presentationEmail.id?.id.value),
        emailId: presentationEmail.id,
        isFirstEmailInThreadDetail: isFirstEmailInThreadDetail,
        isLastEmailInThreadDetail: isLastEmailInThreadDetail,
        threadSubject: isFirstEmailInThreadDetail
          ? emailIdsPresentation.values.last?.subject
          : null,
        onToggleThreadDetailCollapseExpand: () {
          toggleThreadDetailCollapeExpand(presentationEmail);
        },
      );
    }).toList();
  }
}