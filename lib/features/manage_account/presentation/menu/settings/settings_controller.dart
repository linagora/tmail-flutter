import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';

class SettingsController extends GetxController {
  final manageAccountDashboardController = Get.find<ManageAccountDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  void selectSettings(AccountMenuItem accountMenuItem) {
    log('SettingsController::selectSettings(): $accountMenuItem');
    manageAccountDashboardController.selectAccountMenuItem(accountMenuItem);
    manageAccountDashboardController.settingsPageLevel.value = SettingsPageLevel.level1;
  }

  void backToUniversalSettings() {
    log('SettingsController::backToUniversalSettings()');
    manageAccountDashboardController.clearInputFormView();
    manageAccountDashboardController.selectAccountMenuItem(AccountMenuItem.none);
    manageAccountDashboardController.settingsPageLevel.value = SettingsPageLevel.universal;
  }
}