
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/presentation/views/text/slogan_builder.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/user_setting_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ManageAccountDashBoardView extends GetWidget<ManageAccountDashBoardController>
    with UserSettingPopupMenuMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  ManageAccountDashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.isMenuDrawerOpen && _responsiveUtils.isWebDesktop(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.closeMenuDrawer();
      });
    }

    return Scaffold(
      key: controller.menuDrawerKey,
      backgroundColor: Colors.white,
      drawerEnableOpenDragGesture: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ResponsiveWidget(
            responsiveUtils: _responsiveUtils,
            desktop: Column(children: [
              Row(children: [
                Container(width: 256, color: Colors.white,
                    padding: const EdgeInsets.only(top: 25, bottom: 25, left: 32),
                    child: Row(children: [
                      (SloganBuilder(arrangedByHorizontal: true)
                        ..setSloganText(AppLocalizations.of(context).app_name)
                        ..setSloganTextAlign(TextAlign.center)
                        ..setSloganTextStyle(const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))
                        ..setSizeLogo(24)
                        ..addOnTapCallback(() => controller.backToMailboxDashBoard(context))
                        ..setLogo(_imagePaths.icLogoTMail))
                          .build(),
                      Obx(() {
                        if (controller.appInformation.value != null) {
                          return Padding(padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'v.${controller.appInformation.value!.version}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.w500),
                              ));
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    ])
                ),
                Expanded(child: Padding(
                    padding: const EdgeInsets.only(right: 10, top: 16, bottom: 10, left: 48),
                    child: _buildRightHeader(context)))
              ]),
              Expanded(child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(child: ManageAccountMenuView(), width: _responsiveUtils.defaultSizeMenu),
                  Expanded(child: Container(
                    color: AppColor.colorBgDesktop,
                    child: Column(children: [
                      Obx(() {
                        if (controller.vacationResponse.value?.vacationResponderIsValid == true) {
                          return VacationNotificationMessageWidget(
                              margin: const EdgeInsets.only(
                                  top: 16,
                                  left: BuildUtils.isWeb ? 24 : 16,
                                  right: BuildUtils.isWeb ? 24 : 16),
                              fromAccountDashBoard: true,
                              vacationResponse: controller.vacationResponse.value!,
                              actionGotoVacationSetting: !controller.inVacationSettings()
                                  ? () => controller.selectAccountMenuItem(AccountMenuItem.vacation)
                                  : null,
                              actionEndNow: () => controller.disableVacationResponder());
                        } else if ((controller.vacationResponse.value?.vacationResponderIsWaiting == true
                            || controller.vacationResponse.value?.vacationResponderIsStopped == true)
                            && controller.accountMenuItemSelected.value == AccountMenuItem.vacation) {
                          return VacationNotificationMessageWidget(
                              margin: const EdgeInsets.only(
                                  top: 16,
                                  left: BuildUtils.isWeb ? 24 : 16,
                                  right: BuildUtils.isWeb ? 24 : 16),
                              fromAccountDashBoard: true,
                              vacationResponse: controller.vacationResponse.value!,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              leadingIcon: const Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(Icons.timer, size: 20),
                              ));
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
            mobile: SettingsView(closeAction: () => controller.backToMailboxDashBoard(context))
        ),
      ),
    );
  }

  Widget _buildRightHeader(BuildContext context) {
    return Row(children: [
      const Spacer(),
      const SizedBox(width: 16),
      Obx(() => (AvatarBuilder()
          ..text(controller.userProfile.value?.getAvatarText() ?? '')
          ..backgroundColor(Colors.white)
          ..textColor(Colors.black)
          ..context(context)
          ..addOnTapAvatarActionWithPositionClick((position) =>
              controller.openPopupMenuAction(context, position, popupMenuUserSettingActionTile(context,
                  controller.userProfile.value,
                  onLogoutAction: () {
                      controller.logout(controller.sessionCurrent.value, controller.accountId.value);
                    },
                  onSettingAction: ()  {
                    popBack();
                    controller.goToSettings();
                  })))
          ..addBoxShadows([const BoxShadow(
              color: AppColor.colorShadowBgContentEmail,
              spreadRadius: 1, blurRadius: 1, offset: Offset(0, 0.5))])
          ..size(48))
        .build()),
      const SizedBox(width: 16)
    ]);
  }

  Widget _viewDisplayedOfAccountMenuItem() {
    return Obx(() {
      switch(controller.accountMenuItemSelected.value) {
        case AccountMenuItem.profiles:
          return ProfilesView();
        case AccountMenuItem.languageAndRegion:
          return LanguageAndRegionView();
        case AccountMenuItem.emailRules:
          if(controller.checkAvailableRuleFilterInSession()){
            return EmailRulesView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.forward:
          if(controller.checkAvailableForwardInSession()){
            return ForwardView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.vacation:
          return VacationView();
        default:
          return const SizedBox.shrink();
      }
    });
  }
}