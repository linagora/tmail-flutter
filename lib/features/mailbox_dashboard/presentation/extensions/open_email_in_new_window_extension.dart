import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension OpenEmailInNewWindowExtension on MailboxDashBoardController {
  Future<void> loadOpenEmailInNewWindowConfig() async {
    try {
      final preferencesManager = getBinding<PreferencesSettingManager>();
      if (preferencesManager != null) {
        final config = await preferencesManager.getOpenEmailInNewWindowConfig();
        isOpenEmailInNewWindowEnabled.value = config.isEnabled;
        log('OpenEmailInNewWindowExtension::loadOpenEmailInNewWindowConfig: isEnabled = ${config.isEnabled}');
      }
    } catch (e) {
      log('OpenEmailInNewWindowExtension::loadOpenEmailInNewWindowConfig: error = $e');
      isOpenEmailInNewWindowEnabled.value = false;
    }
  }
}
