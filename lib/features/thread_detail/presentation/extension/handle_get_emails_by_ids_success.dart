import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/email_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleGetEmailsByIdsSuccess on ThreadDetailController {
  void handleGetEmailsByIdsSuccess(GetEmailsByIdsSuccess success) {
    final currentRoute = mailboxDashBoardController.dashboardRoute.value;
    if (currentRoute != DashboardRoutes.threadDetailed) {
      return;
    }

    final selectedEmailId = mailboxDashBoardController.selectedEmail.value?.id;
    final isLoadMore = emailIdsPresentation.values.whereNotNull().isNotEmpty;
    
    for (var presentationEmail in success.presentationEmails) {
      if (presentationEmail.id == null) continue;

      if (success.updateCurrentThreadDetail) {
        emailIdsPresentation[presentationEmail.id!] = presentationEmail.copyWith(
          emailInThreadStatus: emailIdsPresentation[presentationEmail.id!]
            ?.emailInThreadStatus ?? EmailInThreadStatus.collapsed,
        );
        continue;
      }

      if (presentationEmail.id == selectedEmailId) {
        EmailBindings(currentEmailId: presentationEmail.id).dependencies();
        currentExpandedEmailId.value = presentationEmail.id;
      }
      emailIdsPresentation[presentationEmail.id!] = presentationEmail.copyWith(
        emailInThreadStatus: presentationEmail.id == selectedEmailId
          ? EmailInThreadStatus.expanded
          : EmailInThreadStatus.collapsed,
      );
    }

    if (!isLoadMore) return;
    
    final currentExpandedEmailIndex = currentExpandedEmailId.value == null
      ? -1
      : emailIdsPresentation.keys.toList().indexOf(currentExpandedEmailId.value!);
    final firstLoadedMoreEmailId = success.presentationEmails.firstOrNull?.id;
    final firstLoadedMoreEmailIndex = firstLoadedMoreEmailId == null
      ? -1
      : emailIdsPresentation.keys.toList().indexOf(firstLoadedMoreEmailId);
    if (currentExpandedEmailIndex == -1 || firstLoadedMoreEmailIndex == -1) {
      return;
    }

    final currentScrollPosition = scrollController?.position.pixels;
    final maxScrollExtent = scrollController?.position.maxScrollExtent;
    final currentBottomScrollPosition = currentScrollPosition != null
        && maxScrollExtent != null
      ? maxScrollExtent - currentScrollPosition
      : null;
    
    if (currentBottomScrollPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final newMaxScrollExtent = scrollController?.position.maxScrollExtent;
        if (newMaxScrollExtent == null) return;

        if (currentExpandedEmailIndex < firstLoadedMoreEmailIndex) {
          return;
        } else if (newMaxScrollExtent != maxScrollExtent!) {
          scrollController?.jumpTo(newMaxScrollExtent - currentBottomScrollPosition);
        }
      });
    }
  }
}