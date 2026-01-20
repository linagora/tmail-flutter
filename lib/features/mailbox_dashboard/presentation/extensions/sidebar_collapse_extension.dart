import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension SidebarCollapseExtension on MailboxDashBoardController {
  Future<void> loadSidebarConfig() async {
    try {
      final preferencesManager = getBinding<PreferencesSettingManager>();
      if (preferencesManager != null) {
        final config = await preferencesManager.getSidebarConfig();
        isSidebarExpanded.value = config.isExpanded;
        log('SidebarCollapseExtension::loadSidebarConfig: isExpanded = ${config.isExpanded}');
      }
    } catch (e) {
      log('SidebarCollapseExtension::loadSidebarConfig: error = $e');
      isSidebarExpanded.value = true;
    }
  }

  Future<void> toggleSidebar() async {
    final newValue = !isSidebarExpanded.value;
    isSidebarExpanded.value = newValue;

    try {
      final preferencesManager = getBinding<PreferencesSettingManager>();
      if (preferencesManager != null) {
        await preferencesManager.updateSidebar(newValue);
        log('SidebarCollapseExtension::toggleSidebar: saved isExpanded = $newValue');
      }
    } catch (e) {
      log('SidebarCollapseExtension::toggleSidebar: error saving = $e');
    }
  }
}
