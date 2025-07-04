import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/contact_support_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/export_trace_log_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';

class SettingsController extends GetxController with ContactSupportMixin {
  final manageAccountDashboardController = Get.find<ManageAccountDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  void selectSettings(AccountMenuItem accountMenuItem) => manageAccountDashboardController.selectSettings(accountMenuItem);

  void backToUniversalSettings() => manageAccountDashboardController.backToUniversalSettings();

  void onBackSettingAction(BuildContext context) {
    if (manageAccountDashboardController.settingsPageLevel.value ==
        SettingsPageLevel.universal) {
      manageAccountDashboardController.backToMailboxDashBoard(context: context);
    } else {
      backToUniversalSettings();
    }
  }

  void showExportTraceLogConfirmDialog(BuildContext context) {
    manageAccountDashboardController.showExportTraceLogConfirmDialog(context);
  }
}