import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_manager.dart';

extension RefreshThreadDetailOnSettingChanged on ThreadDetailManager {
  void refreshThreadDetailOnSettingChanged() {
    if (threadDetailWasEnabled != isThreadDetailEnabled) {
      threadDetailWasEnabled = isThreadDetailEnabled;
      if (PlatformInfo.isWeb &&
          mailboxDashBoardController.isThreadDetailedViewVisible) {
        mailboxDashBoardController.dispatchThreadDetailUIAction(
          ResyncThreadDetailWhenSettingChangedAction(),
        );
      } else {
        mailboxDashBoardController.selectedEmail.refresh();
      }
    }
  }
}