import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';

class SettingsController extends GetxController {
  final manageAccountDashboardController = Get.find<ManageAccountDashBoardController>();

  void selectSettings(AccountMenuItem accountMenuItem) {
    log('SettingsController::selectSettings(): $accountMenuItem');
    manageAccountDashboardController.selectAccountMenuItem(accountMenuItem);
    manageAccountDashboardController.settingsPageLevel.value = SettingsPageLevel.level1;
  }

  void backToUniversalSettings() {
    log('SettingsController::backToUniversalSettings()');
    manageAccountDashboardController.selectAccountMenuItem(AccountMenuItem.none);
    manageAccountDashboardController.settingsPageLevel.value = SettingsPageLevel.universal;
  }
}