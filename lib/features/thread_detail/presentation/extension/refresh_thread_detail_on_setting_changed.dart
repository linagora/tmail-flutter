import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension RefreshThreadDetailOnSettingChanged on ThreadDetailController {
  void refreshThreadDetailOnSettingChanged() {
    if (threadDetailWasEnabled != isThreadDetailEnabled) {
      threadDetailWasEnabled = isThreadDetailEnabled;
      mailboxDashBoardController.selectedEmail.refresh();
    }
  }
}