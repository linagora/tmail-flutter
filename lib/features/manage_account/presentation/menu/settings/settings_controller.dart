import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

class SettingsController extends GetxController {
  final manageAccountDashboardController = Get.find<ManageAccountDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();
  final settingScrollController = ScrollController();

  void selectSettings(AccountMenuItem accountMenuItem) => manageAccountDashboardController.selectSettings(accountMenuItem);

  void backToUniversalSettings() => manageAccountDashboardController.backToUniversalSettings();

  @override
  void onClose() {
    settingScrollController.dispose();
    super.onClose();
  }
}