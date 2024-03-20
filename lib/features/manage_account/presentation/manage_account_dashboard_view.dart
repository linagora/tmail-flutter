
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/presentation/views/text/slogan_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/state/banner_state.dart';
import 'package:tmail_ui_user/features/base/widget/application_version_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/user_setting_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/always_read_receipt/always_read_receipt_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/widgets/forward_warning_banner.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/mailbox_visibility_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ManageAccountDashBoardView extends GetWidget<ManageAccountDashBoardController>
    with UserSettingPopupMenuMixin {

  ManageAccountDashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawerEnableOpenDragGesture: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ResponsiveWidget(
            responsiveUtils: controller.responsiveUtils,
            desktop: Column(children: [
              Row(children: [
                Container(width: 256, color: Colors.white,
                    padding: SettingsUtils.getPaddingHeaderSetting(context),
                    child: Row(children: [
                      SloganBuilder(
                        sizeLogo: 24,
                        text: AppLocalizations.of(context).app_name,
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                        logoSVG: controller.imagePaths.icTMailLogo,
                        onTapCallback: () => controller.backToMailboxDashBoard(context: context),
                      ),
                      ApplicationVersionWidget(
                        applicationManager: controller.applicationManager
                      )
                    ])
                ),
                Expanded(child: Padding(
                    padding: SettingsUtils.getPaddingRightHeaderSetting(context),
                    child: _buildRightHeader(context)))
              ]),
              Expanded(child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: ResponsiveUtils.defaultSizeMenu,
                    child: ManageAccountMenuView()
                  ),
                  Expanded(child: Container(
                    color: AppColor.colorBgDesktop,
                    child: Column(children: [
                      Obx(() {
                        if (controller.vacationResponse.value?.vacationResponderIsValid == true) {
                          return VacationNotificationMessageWidget(
                              margin: const EdgeInsets.only(
                                  top: 16,
                                  left: PlatformInfo.isWeb ? 24 : 16,
                                  right: PlatformInfo.isWeb ? 24 : 16),
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
                                  left: PlatformInfo.isWeb ? 24 : 16,
                                  right: PlatformInfo.isWeb ? 24 : 16),
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
                      Obx(() {
                        if (controller.forwardWarningBannerState.value == BannerState.enabled &&
                          controller.accountMenuItemSelected.value == AccountMenuItem.forward) {
                          return ForwardWarningBanner();
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
            mobile: SettingsView(closeAction: () => controller.backToMailboxDashBoard(context: context))
        ),
      ),
    );
  }

  Widget _buildRightHeader(BuildContext context) {
    return Row(children: [
      const Spacer(),
      const SizedBox(width: 16),
      Obx(() => (AvatarBuilder()
          ..text(controller.accountId.value != null
              ? controller.sessionCurrent?.username.firstCharacter ?? ''
              : ''
            )
          ..backgroundColor(Colors.white)
          ..textColor(Colors.black)
          ..context(context)
          ..addOnTapAvatarActionWithPositionClick((position) {
            return controller.openPopupMenuAction(
              context,
              position,
              popupMenuUserSettingActionTile(
                context,
                controller.sessionCurrent?.username,
                onLogoutAction: () {
                  popBack();
                  controller.logout(controller.sessionCurrent, controller.accountId.value);
                }
              )
            );
          })
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
          return const LanguageAndRegionView();
        case AccountMenuItem.emailRules:
          if(controller.isRuleFilterCapabilitySupported){
            return EmailRulesView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.alwaysReadReceipt:
          if(controller.isServerSettingsCapabilitySupported){
            return const AlwaysReadReceiptView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.forward:
          if(controller.isForwardCapabilitySupported){
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