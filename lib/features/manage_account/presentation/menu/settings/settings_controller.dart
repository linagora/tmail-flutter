import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/web_link_generator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/oidc/response/oidc_user_info.dart';
import 'package:tmail_ui_user/features/base/mixin/contact_support_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/export_trace_log_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/handle_profile_setting_action_type_click_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class SettingsController extends GetxController with ContactSupportMixin {
  final manageAccountDashboardController = Get.find<ManageAccountDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  void selectSettings(BuildContext context, AccountMenuItem accountMenuItem) {
    if (accountMenuItem == AccountMenuItem.signOut) {
      manageAccountDashboardController.handleProfileSettingActionTypeClick(
        context: context,
        actionType: ProfileSettingActionType.signOut,
      );
    } else {
      manageAccountDashboardController.selectSettings(accountMenuItem);
    }
  }

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

  void goToCommonSetting(OidcUserInfo oidcUserInfo) {
    final commonSettingUrl = WebLinkGenerator.safeGenerateWebLink(
      workplaceFqdn: oidcUserInfo.workplaceFqdn!,
      slug: 'settings',
    );
    log('$runtimeType::goToCommonSetting: CommonSettingUrl is $commonSettingUrl');
    AppUtils.launchLink(commonSettingUrl);
  }
}