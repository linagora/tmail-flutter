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

    if (isThreadDetailEnabled) {
      final currentThreadIndex = availableThreadIds.indexOf(currentThreadId!);
      final nextThreadIndex = currentThreadIndex + 1;
      final nextThreadId = availableThreadIds[nextThreadIndex];
      _preparePageWithIndex(nextThreadIndex);
      _goToPageWithEmail(
        currentDisplayedEmails.firstWhereOrNull(
          (presentationEmail) => presentationEmail.threadId == nextThreadId,
        ),
      );
      return;
    }

    final currentEmailIndex = currentDisplayedEmails.indexOf(
      mailboxDashBoardController.selectedEmail.value!,
    );
    final nextEmailIndex = currentEmailIndex + 1;
    final nextEmail = currentDisplayedEmails[nextEmailIndex];
    _preparePageWithIndex(nextEmailIndex);
    _goToPageWithEmail(nextEmail);
  }

  bool get previousAvailable => isThreadDetailEnabled
      ? currentThreadId != availableThreadIds.firstOrNull
      : currentEmailId != currentDisplayedEmails.firstOrNull?.id;
  void onPrevious() {
    if (!previousAvailable) return;

    if (isThreadDetailEnabled) {
      final currentThreadIndex = availableThreadIds.indexOf(currentThreadId!);
      final previousThreadIndex = currentThreadIndex - 1;
      final previousThreadId = availableThreadIds[previousThreadIndex];
      _preparePageWithIndex(previousThreadIndex);
      _goToPageWithEmail(
        currentDisplayedEmails.firstWhereOrNull(
          (presentationEmail) => presentationEmail.threadId == previousThreadId,
        ),
      );
      return;
    }

    final currentEmailIndex = currentDisplayedEmails.indexOf(
      mailboxDashBoardController.selectedEmail.value!,
    );
    final previousEmailIndex = currentEmailIndex - 1; 
    final previousEmail = currentDisplayedEmails[previousEmailIndex];
    _preparePageWithIndex(previousEmailIndex);
    _goToPageWithEmail(previousEmail);
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
        url: presentationEmail!.routeWeb!
      );
    }
  }
}