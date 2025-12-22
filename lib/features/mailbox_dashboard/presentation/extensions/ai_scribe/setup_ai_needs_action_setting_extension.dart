import 'package:get/get.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:server_settings/server_settings/tmail_server_settings_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension SetupAiNeedsActionSettingExtension on MailboxDashBoardController {
  void setupAINeedsActionSetting({TMailServerSettingOptions? options}) {
    if (options != null) {
      isAINeedsActionSettingEnabled.value = options.isAINeedsActionEnabled;
    } else {
      isAINeedsActionSettingEnabled.value = false;
    }

    if (isAINeedsActionSettingEnabled.isTrue) {
      dispatchMailboxUIAction(AutoCreateActionRequiredFolderMailboxAction());
    } else {
      dispatchMailboxUIAction(AutoRemoveActionRequiredFolderMailboxAction());
    }
  }
}
