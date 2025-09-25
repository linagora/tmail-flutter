import 'package:core/utils/platform_info.dart';
import 'package:flutter/animation.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/thread_detail_next_previous_actions.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension OnThreadPageChanged on ThreadDetailController {
  void onThreadPageChanged(int index) {
    if (index > threadDetailManager.currentMobilePageViewIndex.value) {
      onNext();
    } else if (index < threadDetailManager.currentMobilePageViewIndex.value) {
      onPrevious();
    }
  }

  bool get nextAvailable =>
      PlatformInfo.isWeb && threadDetailManager.nextAvailable;
  bool get previousAvailable =>
      PlatformInfo.isWeb && threadDetailManager.previousAvailable;

  void onNext() {
    if (PlatformInfo.isWeb && currentExpandedEmailId.value != null) {
      mailboxDashBoardController.dispatchEmailUIAction(
        CollapseEmailInThreadDetailAction(currentExpandedEmailId.value!),
      );
    }
    loadThreadOnThreadChanged = isThreadDetailEnabled;
    threadDetailManager.onNext();
  }

  void onNextMobile() {
    loadThreadOnThreadChanged = isThreadDetailEnabled;
    threadDetailManager.pageController?.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  void onPrevious() {
    if (PlatformInfo.isWeb && currentExpandedEmailId.value != null) {
      mailboxDashBoardController.dispatchEmailUIAction(
        CollapseEmailInThreadDetailAction(currentExpandedEmailId.value!),
      );
    }
    loadThreadOnThreadChanged = isThreadDetailEnabled;
    threadDetailManager.onPrevious();
  }

  void onPreviousMobile() {
    loadThreadOnThreadChanged = isThreadDetailEnabled;
    threadDetailManager.pageController?.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }
}
