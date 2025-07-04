import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/mailbox_visibility_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/setting_app_bar.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_first_level_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/notification/notification_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/preferences_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';

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
          if (controller.manageAccountDashboardController.vacationResponse.value?.vacationResponderIsValid == true) {
            return VacationNotificationMessageWidget(
              margin: const EdgeInsetsDirectional.only(start: 12, end: 12, top: 8),
              fromAccountDashBoard: true,
              vacationResponse: controller.manageAccountDashboardController.vacationResponse.value!,
              actionGotoVacationSetting: !controller.manageAccountDashboardController.inVacationSettings()
                ? () => controller.manageAccountDashboardController.selectAccountMenuItem(AccountMenuItem.vacation)
                : null,
              actionEndNow: controller.manageAccountDashboardController.disableVacationResponder
            );
          } else if ((controller.manageAccountDashboardController.vacationResponse.value?.vacationResponderIsWaiting == true
              || controller.manageAccountDashboardController.vacationResponse.value?.vacationResponderIsStopped == true)
              && controller.manageAccountDashboardController.inVacationSettings()) {
            return VacationNotificationMessageWidget(
              margin: const EdgeInsetsDirectional.only(start: 12, end: 12, top: 8),
              fromAccountDashBoard: true,
              vacationResponse: controller.manageAccountDashboardController.vacationResponse.value!,
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
          return ProfilesView(responsiveUtils: controller.responsiveUtils);
        case AccountMenuItem.languageAndRegion:
          if (controller.manageAccountDashboardController.isLanguageSettingDisplayed) {
            return const LanguageAndRegionView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.emailRules:
          if (controller.manageAccountDashboardController.isRuleFilterCapabilitySupported) {
            return EmailRulesView();
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
            return VacationView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.mailboxVisibility:
          return MailboxVisibilityView();
        case AccountMenuItem.notification:
          return const NotificationView();
        default:
          return const SizedBox.shrink();
      }
    });
  }
}