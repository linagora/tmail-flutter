import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_manager.dart';

extension InitializeThreadDetailManager on ThreadDetailManager {
  void initializeThreadDetailManager(
    List<PresentationEmail> currentDisplayedEmails,
    PresentationEmail? selectedEmail,
  ) {
    if (PlatformInfo.isMobile) {
      final currentThreadId = selectedEmail?.threadId;
      final currentEmailId = selectedEmail?.id;

      if ((isThreadDetailEnabled && currentThreadId == null) ||
          (!isThreadDetailEnabled && currentEmailId == null)) {
        return;
      }

      int currentPageIndex = 0;

      if (isThreadDetailEnabled && currentThreadId != null) {
        final uniqueThreadIds = currentDisplayedEmails.uniqueThreadIds;
        availableThreadIds.value = uniqueThreadIds;
        currentPageIndex = uniqueThreadIds.indexOf(currentThreadId);
      } else if (currentEmailId != null) {
        currentPageIndex =
            currentDisplayedEmails.listEmailIds.indexOf(currentEmailId);
      }

      pageController ??= PageController(initialPage: currentPageIndex);
      currentMobilePageViewIndex.value = currentPageIndex;
    } else {
      availableThreadIds.value = currentDisplayedEmails.uniqueThreadIds;
    }
  }
}