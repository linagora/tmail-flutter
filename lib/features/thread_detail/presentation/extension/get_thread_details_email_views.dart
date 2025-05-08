import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/email_bindings.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/load_more_thread_detail_emails.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_collapsed_email.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_load_more_circle.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension GetThreadDetailEmailViews on ThreadDetailController {
  List<Widget> getThreadDetailEmailViews() {
    int? firstEmailNotLoadedIndex;
    if (emailsNotLoadedCount > 0) {
      firstEmailNotLoadedIndex = emailIds.indexOf(
        emailIdsStatus.entries.firstWhereOrNull(
          (entry) => entry.value == EmailInThreadStatus.hidden
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

      if (emailIdsStatus[emailId] == EmailInThreadStatus.hidden) {
        return const SizedBox.shrink();
      }

      final isFirstEmailInThreadDetail = emailIds.indexOf(emailId) == 0;
      final isLastEmailInThreadDetail = emailIds.indexOf(emailId) ==
        emailIds.length - 1;

      if (emailIdsStatus[emailId] == EmailInThreadStatus.collapsed) {
        return ThreadDetailCollapsedEmail(
          presentationEmail: presentationEmail,
          showSubject: false,
          imagePaths: imagePaths,
          responsiveUtils: responsiveUtils,
          mailboxContain: presentationEmail.mailboxContain,
          emailLoaded: null,
          openEmailAddressDetailAction: (context, emailAddress) {
            // TODO: Next PR
          },
          onToggleThreadDetailCollapseExpand: () {
            final isInitialized = getBinding<SingleEmailController>(
              tag: emailId.id.value,
            ) != null;
            if (!isInitialized) {
              EmailBindings(initialEmail: presentationEmail).dependencies();
            }
            emailIdsStatus[emailId] = EmailInThreadStatus.expanded;
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
          emailIdsStatus[emailId] = EmailInThreadStatus.collapsed;
        },
      );
    }).toList();
  }
}