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

    final isLoadMore = emailIdsPresentation.values.whereNotNull().isNotEmpty;
    final currentScrollPosition = scrollController?.position.pixels;
    final maxScrollExtent = scrollController?.position.maxScrollExtent;
    final currentBottomScrollPosition = currentScrollPosition != null
        && maxScrollExtent != null
      ? maxScrollExtent - currentScrollPosition
      : null;
    
    for (var presentationEmail in success.presentationEmails) {
      if (presentationEmail.id == null) continue;
      if (presentationEmail.id == emailIds.last) {
        EmailBindings(currentEmailId: presentationEmail.id).dependencies();
        currentExpandedEmailId.value = presentationEmail.id;
      }
      emailIdsPresentation[presentationEmail.id!] = presentationEmail.copyWith(
        emailInThreadStatus: presentationEmail.id == emailIds.last
          ? EmailInThreadStatus.expanded
          : EmailInThreadStatus.collapsed,
      );
    }

    if (!isLoadMore) return;
    
    final currentExpandedEmailIndex = emailIds.indexOf(emailIdsPresentation
      .entries
      .firstWhereOrNull(
        (entry) => entry.value?.emailInThreadStatus == EmailInThreadStatus.expanded,
      )
      ?.key);
    final firstLoadedMoreEmailIndex = emailIds
      .indexOf(success.presentationEmails.firstOrNull?.id);
    if (currentExpandedEmailIndex == -1 || firstLoadedMoreEmailIndex == -1) {
      return;
    }
    
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