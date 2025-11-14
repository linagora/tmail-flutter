import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/validate_setting_capability_supported_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/identities_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/keyboard_shortcuts/keyboard_shortcuts_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/mailbox_visibility_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/setting_app_bar.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_first_level_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/notification/notification_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/preferences_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/storage_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';

class SettingsView extends GetWidget<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => SettingAppBar(
          pageLevel: controller
              .manageAccountDashboardController
              .settingsPageLevel
              .value,
          accountMenuItem: controller
              .manageAccountDashboardController
              .accountMenuItemSelected
              .value,
          imagePaths: controller.imagePaths,
          responsiveUtils: controller.responsiveUtils,
          onBackAction: () => controller.onBackSettingAction(context),
          onExportTraceLogAction: () =>
              controller.showExportTraceLogConfirmDialog(context),
        )),
        Obx(() {
          final dashboard = controller.manageAccountDashboardController;
          final vacation = dashboard.vacationResponse.value;
          final isWebDesktopResponsive = controller
              .responsiveUtils
              .isWebDesktop(context);

          if (vacation?.vacationResponderIsValid == true) {
            return VacationNotificationMessageWidget(
              margin: EdgeInsetsDirectional.only(
                start: 12,
                end: 12,
                top: isWebDesktopResponsive ? 8 : 0,
                bottom: isWebDesktopResponsive ? 0 : 16,
              ),
              fromAccountDashBoard: true,
              vacationResponse: vacation!,
              actionGotoVacationSetting: !dashboard.inVacationSettings()
                ? () => dashboard.selectAccountMenuItem(AccountMenuItem.vacation)
                : null,
              actionEndNow: dashboard.disableVacationResponder
            );
          } else if (vacation?.vacationResponderIsWaiting == true &&
              dashboard.inVacationSettings()) {
            return VacationNotificationMessageWidget(
              margin: EdgeInsetsDirectional.only(
                start: 12,
                end: 12,
                top: isWebDesktopResponsive ? 8 : 0,
                bottom: isWebDesktopResponsive ? 0 : 16,
              ),
              fromAccountDashBoard: true,
              vacationResponse: vacation!,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              leadingIcon: const Padding(
                padding: EdgeInsetsDirectional.only(end: 12),
                child: Icon(Icons.timer, size: 20),
              )
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Expanded(child: _bodySettingsScreen())
      ]
    );
  }

  Widget _bodySettingsScreen() {
    return Obx(() {
      switch (controller.manageAccountDashboardController.settingsPageLevel.value) {
        case SettingsPageLevel.universal:
          return const SettingsFirstLevelView();
        case SettingsPageLevel.level1:
          return _viewDisplayedOfAccountMenuItem();
      }
    });
  }

  Widget _viewDisplayedOfAccountMenuItem() {
    return Obx(() {
      switch(controller.manageAccountDashboardController.accountMenuItemSelected.value) {
        case AccountMenuItem.profiles:
          return const IdentitiesView();
        case AccountMenuItem.languageAndRegion:
          if (controller.manageAccountDashboardController.isLanguageSettingDisplayed) {
            return const LanguageAndRegionView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.emailRules:
          if (controller.manageAccountDashboardController.isRuleFilterCapabilitySupported) {
            return const EmailRulesView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.preferences:
          if (controller.manageAccountDashboardController.isServerSettingsCapabilitySupported) {
            return const PreferencesView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.forward:
          if (controller.manageAccountDashboardController.isForwardCapabilitySupported) {
            return ForwardView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.vacation:
          if (controller.manageAccountDashboardController.isVacationCapabilitySupported) {
            return const VacationView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.mailboxVisibility:
          return MailboxVisibilityView();
        case AccountMenuItem.notification:
          return const NotificationView();
        case AccountMenuItem.storage:
          if (controller.manageAccountDashboardController.octetsQuota.value != null &&
              controller.manageAccountDashboardController.octetsQuota.value?.storageAvailable == true &&
              controller.manageAccountDashboardController.isStorageCapabilitySupported) {
            return const StorageView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.keyboardShortcuts:
          return const KeyboardShortcutsView();
        default:
          return const SizedBox.shrink();
      }
    });
  }
}