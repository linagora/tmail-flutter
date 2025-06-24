import 'package:core/utils/platform_info.dart';
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
    if (currentExpandedEmailId.value != null) {
      mailboxDashBoardController.dispatchEmailUIAction(
        CollapseEmailInThreadDetailAction(currentExpandedEmailId.value!),
      );
    }
    threadDetailManager.onNext();
  }

  void onPrevious() {
    if (currentExpandedEmailId.value != null) {
      mailboxDashBoardController.dispatchEmailUIAction(
        CollapseEmailInThreadDetailAction(currentExpandedEmailId.value!),
      );
    }
    threadDetailManager.onPrevious();
  }
}
