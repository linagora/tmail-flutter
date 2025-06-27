import 'package:collection/collection.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_manager.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

extension ThreadDetailNextPreviousActions on ThreadDetailManager {
  bool get nextAvailable => isThreadDetailEnabled
      ? currentThreadId != availableThreadIds.lastOrNull
      : currentEmailId != currentDisplayedEmails.lastOrNull?.id;
  void onNext() {
    if (!nextAvailable) return;

    final currentIndex = isThreadDetailEnabled
        ? availableThreadIds.indexOf(currentThreadId!)
        : currentDisplayedEmails
            .indexOf(mailboxDashBoardController.selectedEmail.value!);
    _navigate(currentIndex + 1, isThreadDetailEnabled);
  }

  bool get previousAvailable => isThreadDetailEnabled
      ? currentThreadId != availableThreadIds.firstOrNull
      : currentEmailId != currentDisplayedEmails.firstOrNull?.id;
  void onPrevious() {
    if (!previousAvailable) return;

    final currentIndex = isThreadDetailEnabled
        ? availableThreadIds.indexOf(currentThreadId!)
        : currentDisplayedEmails
            .indexOf(mailboxDashBoardController.selectedEmail.value!);
    _navigate(currentIndex - 1, isThreadDetailEnabled);
  }

  void _preparePageWithIndex(int index) {
    currentMobilePageViewIndex.value = index;
    pageController?.dispose();
    pageController = PageController(initialPage: index);
  }

  void _goToPageWithEmail(PresentationEmail? presentationEmail) {
    mailboxDashBoardController.setSelectedEmail(presentationEmail);
    if (PlatformInfo.isWeb && presentationEmail?.routeWeb != null) {
      RouteUtils.replaceBrowserHistory(
          title: 'Email-${presentationEmail?.id?.id.value ?? ''}',
          url: presentationEmail!.routeWeb!);
    }
  }

  void _navigateToEmail(int emailIndex) {
    final email = currentDisplayedEmails[emailIndex];
    _preparePageWithIndex(emailIndex);
    _goToPageWithEmail(email);
  }

  void _navigateToThread(int threadIndex) {
    final threadId = availableThreadIds[threadIndex];
    final email = currentDisplayedEmails.firstWhereOrNull(
      (presentationEmail) => presentationEmail.threadId == threadId,
    );
    _preparePageWithIndex(threadIndex);
    _goToPageWithEmail(email);
  }

  void _navigate(int index, bool isThreadDetailEnabled) {
    isThreadDetailEnabled ? _navigateToThread(index) : _navigateToEmail(index);
  }
}
