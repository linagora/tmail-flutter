import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/load_more_thread_detail_emails.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/toggle_thread_detail_collape_expand.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_collapsed_email.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_load_more_circle.dart';

extension GetThreadDetailEmailViews on ThreadDetailController {
  List<Widget> getThreadDetailEmailViews() {
    int? firstEmailNotLoadedIndex;
    if (emailsToLoadMoreCount > 0) {
      final firstNotLoadedEmailId = emailIdsPresentation.entries.firstWhereOrNull(
        (entry) => entry.value == null
      )?.key;
      if (firstNotLoadedEmailId == null) {
        firstEmailNotLoadedIndex = -1;
      } else {
        firstEmailNotLoadedIndex = emailIdsPresentation
          .keys
          .toList()
          .indexOf(firstNotLoadedEmailId);
      }
    }

    return emailIdsPresentation.entries.map((entry) {
      final emailId = entry.key;
      final presentationEmail = entry.value;
      final indexOfEmailId = emailIdsPresentation.keys.toList().indexOf(emailId);
      if (presentationEmail == null) {
        if (indexOfEmailId != firstEmailNotLoadedIndex) {
          return const SizedBox.shrink();
        }

        return ThreadDetailLoadMoreCircle(
          count: emailsToLoadMoreCount,
          onTap: loadMoreThreadDetailEmails,
          imagePaths: imagePaths,
          isLoading: loadingThreadDetail,
        );
      }

      if (presentationEmail.emailInThreadStatus == null) {
        return const SizedBox.shrink();
      }

      final isFirstEmailInThreadDetail = indexOfEmailId == 0;

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
          openEmailAddressDetailAction: (context, emailAddress) {
            // TODO: Next PR
          },
          onToggleThreadDetailCollapseExpand: () {
            toggleThreadDetailCollapeExpand(presentationEmail);
          },
        );
      }

      return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 16),
        child: EmailView(
          key: GlobalObjectKey(presentationEmail.id?.id.value ?? ''),
          isInsideThreadDetailView: true,
          emailId: presentationEmail.id,
          isFirstEmailInThreadDetail: isFirstEmailInThreadDetail,
          threadSubject: isFirstEmailInThreadDetail
            ? emailIdsPresentation.values.last?.subject
            : null,
          onToggleThreadDetailCollapseExpand: () {
            toggleThreadDetailCollapeExpand(presentationEmail);
          },
          scrollController: scrollController,
        ),
      );
    }).toList();
  }
}