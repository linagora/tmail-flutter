import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_mail_shortcut_actions_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/labels/remove_label_from_email_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/load_more_thread_detail_emails.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/thread_detail_load_more_segments.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/thread_detail_on_email_action_click.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/thread_detail_open_email_address_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/toggle_thread_detail_collapse_expand.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_collapsed_email.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_load_more_circle.dart';

extension GetThreadDetailEmailViews on ThreadDetailController {
  List<Widget> getThreadDetailEmailViews({List<Label>? labels}) {
    final loadMoreSegments = Map<LoadMoreIndex, LoadMoreCount>.from(this.loadMoreSegments);
    PresentationEmail? emailDisplayLabel;

    final lastEmail = emailIdsPresentation.values.lastOrNull;

    if (currentExpandedEmailId.value == null) {
      emailDisplayLabel = lastEmail;
    } else  {
      emailDisplayLabel = emailIdsPresentation[currentExpandedEmailId.value];
    }

    final emailLabels = _getLabelsForEmail(
      email: emailDisplayLabel,
      availableLabels: labels,
    );

    return emailIdsPresentation.entries.map((entry) {
      final emailId = entry.key;
      final presentationEmail = entry.value;
      final indexOfEmailId = emailIdsPresentation.keys.toList().indexOf(emailId);
      if (presentationEmail == null) {
        if (loadMoreSegments[indexOfEmailId] == null) {
          return const SizedBox.shrink();
        }

        return ThreadDetailLoadMoreCircle(
          count: loadMoreSegments[indexOfEmailId]!,
          onTap: () => loadMoreThreadDetailEmails(
            loadMoreIndex: indexOfEmailId,
            loadMoreCount: loadMoreSegments[indexOfEmailId]!,
          ),
          imagePaths: imagePaths,
          loadingIndex: indexOfEmailId,
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
              ? lastEmail?.subject
              : null
          ),
          showSubject: isFirstEmailInThreadDetail,
          imagePaths: imagePaths,
          responsiveUtils: responsiveUtils,
          mailboxContain: presentationEmail.findMailboxContain(
            mailboxDashBoardController.mapMailboxById,
          ),
          emailLoaded: null,
          labels: emailLabels,
          onEmailActionClick: threadDetailOnEmailActionClick,
          openEmailAddressDetailAction: (_, emailAddress) {
            openEmailAddressDetailAction(emailAddress);
          },
          onToggleThreadDetailCollapseExpand: () {
            toggleThreadDetailCollapseExpand(presentationEmail);
          },
          onDeleteLabelAction: (label) {
            if (emailDisplayLabel?.id == null) return;
            removeLabelFromEmail(emailDisplayLabel!.id!, label);
          },
        );
      }

      if (isFirstEmailInThreadDetail) {
        return EmailView(
          key: PlatformInfo.isWeb
              ? GlobalObjectKey(presentationEmail.id?.id.value ?? '')
              : null,
          isInsideThreadDetailView: true,
          emailId: presentationEmail.id,
          isFirstEmailInThreadDetail: true,
          threadSubject: lastEmail?.subject,
          onToggleThreadDetailCollapseExpand: () {
            toggleThreadDetailCollapseExpand(presentationEmail);
          },
          onIFrameKeyboardShortcutAction: keyboardShortcutFocusNode != null
            ? onIFrameKeyboardShortcutAction
            : null,
          scrollController: scrollController,
        );
      }

      return EmailView(
        key: PlatformInfo.isWeb
            ? GlobalObjectKey(presentationEmail.id?.id.value ?? '')
            : null,
        isInsideThreadDetailView: true,
        emailId: presentationEmail.id,
        onToggleThreadDetailCollapseExpand: () {
          toggleThreadDetailCollapseExpand(presentationEmail);
        },
        onIFrameKeyboardShortcutAction: keyboardShortcutFocusNode != null
          ? onIFrameKeyboardShortcutAction
          : null,
        scrollController: scrollController,
      );
    }).toList();
  }

  List<Label>? _getLabelsForEmail({
    required PresentationEmail? email,
    required List<Label>? availableLabels,
  }) {
    if (availableLabels == null ||
        availableLabels.isEmpty) {
      return null;
    }

    return email?.getLabelList(availableLabels);
  }
}