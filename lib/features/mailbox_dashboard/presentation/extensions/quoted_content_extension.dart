import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension QuotedContentExtension on MailboxDashBoardController {
  Future<void> loadQuotedContentConfig() async {
    try {
      final preferencesManager = getBinding<PreferencesSettingManager>();
      if (preferencesManager != null) {
        final config = await preferencesManager.getQuotedContentConfig();
        isQuotedContentHiddenByDefault.value = config.isHiddenByDefault;
        log('QuotedContentExtension::loadQuotedContentConfig: isHiddenByDefault = ${config.isHiddenByDefault}');
      }
    } catch (e) {
      log('QuotedContentExtension::loadQuotedContentConfig: error = $e');
      isQuotedContentHiddenByDefault.value = true;
    }
  }
}
