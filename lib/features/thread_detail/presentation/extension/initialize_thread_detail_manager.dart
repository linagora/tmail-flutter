import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_manager.dart';

extension InitializeThreadDetailManager on ThreadDetailManager {
  void initializeThreadDetailManager(
    List<PresentationEmail> currentDisplayedEmails,
  ) {
    availableThreadIds.value = currentDisplayedEmails
        .map((presentationEmail) => presentationEmail.threadId)
        .toSet()
        .nonNulls
        .toList();
    if (availableThreadIds.isEmpty) return;

    final selectedEmail = mailboxDashBoardController.selectedEmail.value;
    if (isThreadDetailEnabled && selectedEmail?.threadId != null) {
      final currentThreadIndex = availableThreadIds.indexOf(
        selectedEmail!.threadId!,
      );
      currentMobilePageViewIndex.value = currentThreadIndex;
    } else if (selectedEmail?.id != null) {
      final currentEmailIndex = currentDisplayedEmails
        .map((email) => email.id)
        .toList()
        .indexOf(selectedEmail?.id);
      currentMobilePageViewIndex.value = currentEmailIndex;
    }

    pageController ??= PageController(
      initialPage: currentMobilePageViewIndex.value,
    );
  }
}