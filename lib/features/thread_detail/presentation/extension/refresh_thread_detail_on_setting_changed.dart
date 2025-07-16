import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_manager.dart';

extension RefreshThreadDetailOnSettingChanged on ThreadDetailManager {
  void refreshThreadDetailOnSettingChanged() {
    if (threadDetailWasEnabled != isThreadDetailEnabled) {
      threadDetailWasEnabled = isThreadDetailEnabled;
      mailboxDashBoardController.selectedEmail.refresh();
    }
  }
}