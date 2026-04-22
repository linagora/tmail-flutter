import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/services/local_settings_service.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';

extension NotifyThreadDetailSettingUpdated on MailboxDashBoardController {
  Future<void> notifyThreadDetailSettingUpdated() async {
    await Get.find<LocalSettingsService>().reload();
    dispatchThreadDetailUIAction(UpdatedThreadDetailSettingAction());
  }
}
