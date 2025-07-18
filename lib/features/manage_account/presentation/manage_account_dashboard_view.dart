import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:cozy/cozy_config_manager/cozy_config_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/navigation_bar/navigation_bar_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/handle_profile_setting_action_type_click_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/mailbox_visibility_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/preferences_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';

class ManageAccountDashBoardView extends GetWidget<ManageAccountDashBoardController> {

  const ManageAccountDashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: Scaffold(
        backgroundColor: controller.responsiveUtils.isWebDesktop(context)
            ? AppColor.colorBgDesktop
            : Colors.white,
        drawerEnableOpenDragGesture: false,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ResponsiveWidget(
              responsiveUtils: controller.responsiveUtils,
              desktop: Column(children: [
                FutureBuilder(
                future: CozyConfigManager().isInsideCozy,
                builder: (context, snapshot) {
                  if (snapshot.data == true) return const SizedBox.shrink();

                  return Obx(() => NavigationBarWidget(
                      imagePaths: controller.imagePaths,
                      accountId: controller.accountId.value,
                      ownEmailAddress: controller.ownEmailAddress.value,
                      onTapApplicationLogoAction: () =>
                          controller.backToMailboxDashBoard(context: context),
                  settingActionTypes: const [ProfileSettingActionType.signOut],
                      onProfileSettingActionTypeClick: (actionType) =>
                        controller.handleProfileSettingActionTypeClick(
                      context: context,
                      actionType: actionType,
                    ),
                    ));
                }
              ),
                Expanded(child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: ResponsiveUtils.defaultSizeMenu,
                      child: ManageAccountMenuView()
                    ),
                    Expanded(child: ColoredBox(
                      color: AppColor.colorBgDesktop,
                      child: Column(children: [
                        Obx(() {
                          if (controller.vacationResponse.value?.vacationResponderIsValid == true) {
                            return VacationNotificationMessageWidget(
                              margin: const EdgeInsetsDirectional.only(top: 16, start: 16, end: 16),
                              fromAccountDashBoard: true,
                              vacationResponse: controller.vacationResponse.value!,
                              actionGotoVacationSetting: !controller.inVacationSettings()
                                ? () => controller.selectAccountMenuItem(AccountMenuItem.vacation)
                                : null,
                              actionEndNow: controller.disableVacationResponder);
                          } else if ((controller.vacationResponse.value?.vacationResponderIsWaiting == true
                              || controller.vacationResponse.value?.vacationResponderIsStopped == true)
                              && controller.accountMenuItemSelected.value == AccountMenuItem.vacation) {
                            return VacationNotificationMessageWidget(
                              margin: const EdgeInsetsDirectional.only(top: 16, start: 16, end: 16),
                              fromAccountDashBoard: true,
                              vacationResponse: controller.vacationResponse.value!,
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
                        Expanded(child: _viewDisplayedOfAccountMenuItem())
                      ]),
                    ))
                  ],
                ))
              ]),
              mobile: const SafeArea(child: SettingsView())
          ),
        ),
      ),
    );
  }

  Widget _viewDisplayedOfAccountMenuItem() {
    return Obx(() {
      switch(controller.accountMenuItemSelected.value) {
        case AccountMenuItem.profiles:
          return ProfilesView(responsiveUtils: controller.responsiveUtils);
        case AccountMenuItem.languageAndRegion:
          if (controller.isLanguageSettingDisplayed) {
            return const LanguageAndRegionView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.emailRules:
          if (controller.isRuleFilterCapabilitySupported){
            return EmailRulesView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.preferences:
          if (controller.isServerSettingsCapabilitySupported){
            return const PreferencesView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.forward:
          if (controller.isForwardCapabilitySupported){
            return ForwardView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.vacation:
          return VacationView();
        case AccountMenuItem.mailboxVisibility:
          return MailboxVisibilityView();
        default:
          return const SizedBox.shrink();
      }
    });
  }
}