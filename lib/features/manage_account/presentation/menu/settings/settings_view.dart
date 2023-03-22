import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/mailbox_visibility_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_first_level_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef CloseSettingsViewAction = void Function();

class SettingsView extends GetWidget<SettingsController> {
  SettingsView({Key? key, this.closeAction}) : super(key: key);

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();
  final CloseSettingsViewAction? closeAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox.fromSize(
              size: const Size.fromHeight(52),
              child: Padding(
                padding: SettingsUtils.getPaddingAppBar(context, _responsiveUtils),
                child: _buildAppbar(context))),
            const Divider(color: AppColor.colorDividerComposer, height: 1),
            Obx(() {
              if (controller.manageAccountDashboardController.vacationResponse.value?.vacationResponderIsValid == true) {
                return VacationNotificationMessageWidget(
                    margin: const EdgeInsets.only(
                        left: BuildUtils.isWeb ? 24 : 16,
                        right: BuildUtils.isWeb ? 24 : 16,
                        top: 16),
                    fromAccountDashBoard: true,
                    vacationResponse: controller.manageAccountDashboardController.vacationResponse.value!,
                    actionEndNow: () => controller.manageAccountDashboardController.disableVacationResponder());
              } else if ((controller.manageAccountDashboardController.vacationResponse.value?.vacationResponderIsWaiting == true
                  || controller.manageAccountDashboardController.vacationResponse.value?.vacationResponderIsStopped == true)
                  && controller.manageAccountDashboardController.inVacationSettings()) {
                return VacationNotificationMessageWidget(
                  margin: const EdgeInsets.only(
                    left: BuildUtils.isWeb ? 24 : 16,
                    right: BuildUtils.isWeb ? 24 : 16,
                    top: 16),
                  fromAccountDashBoard: true,
                  vacationResponse: controller.manageAccountDashboardController.vacationResponse.value!,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  leadingIcon: Padding(
                    padding: EdgeInsets.only(
                      right: AppUtils.isDirectionRTL(context) ? 0 : 16,
                      left: AppUtils.isDirectionRTL(context) ? 16 : 0,
                    ),
                    child: const Icon(Icons.timer, size: 20),
                  )
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
            Expanded(child: _bodySettingsScreen())
          ]
        ),
      ),
    );
  }

  Widget _buildAppbar(BuildContext context) {
    return Obx(() {
      if (controller.manageAccountDashboardController.settingsPageLevel.value == SettingsPageLevel.universal) {
        return _buildUniversalSettingAppBar(context);
      } else {
        return _buildSettingLevel1AppBar(context);
      }
    });
  }

  Widget _buildUniversalSettingAppBar(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(left: 0,child: _buildCloseSettingButton(context)),
        Padding(
          padding: const EdgeInsets.only(left: 50, right: 50),
          child: Text(
            AppLocalizations.of(context).settings,
            maxLines: 1,
            softWrap: CommonTextStyle.defaultSoftWrap,
            overflow: CommonTextStyle.defaultTextOverFlow,
            style: const TextStyle(
              fontSize: 20,
              color: AppColor.colorNameEmail,
              fontWeight: FontWeight.w700))
        )
      ]
    );
  }

  Widget _buildSettingLevel1AppBar(BuildContext context) {
    return Stack(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.backToUniversalSettings,
            customBorder: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Tooltip(
              message: AppLocalizations.of(context).back,
              child: Container(
                color: Colors.transparent,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  SvgPicture.asset(
                      AppUtils.isDirectionRTL(context) ? _imagePaths.icCollapseFolder : _imagePaths.icBack,
                      colorFilter: AppColor.colorTextButton.asFilter(),
                      fit: BoxFit.fill),
                  Container(
                    margin: EdgeInsets.only(
                      left: AppUtils.isDirectionRTL(context) ? 0 : 8,
                      right: AppUtils.isDirectionRTL(context) ? 8 : 0,
                    ),
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Text(
                        AppLocalizations.of(context).settings,
                        maxLines: 1,
                        overflow: CommonTextStyle.defaultTextOverFlow,
                        softWrap: CommonTextStyle.defaultSoftWrap,
                        style: const TextStyle(fontSize: 17, color: AppColor.colorTextButton)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
      Align(
        alignment: Alignment.center,
        child: Text(
          controller.manageAccountDashboardController.accountMenuItemSelected.value.getName(context),
          maxLines: 1,
          overflow: CommonTextStyle.defaultTextOverFlow,
          softWrap: CommonTextStyle.defaultSoftWrap,
          style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)))
    ]);
  }

  Widget _buildCloseSettingButton(BuildContext context) {
    return buildIconWeb(
      icon: SvgPicture.asset(_imagePaths.icClose, width: 28, height: 28, fit: BoxFit.fill),
      tooltip: AppLocalizations.of(context).close,
      onTap: closeAction);
  }

  Widget _bodySettingsScreen() {
    return Obx(() {
      switch (controller.manageAccountDashboardController.settingsPageLevel.value) {
        case SettingsPageLevel.universal:
          return SettingsFirstLevelView();
        case SettingsPageLevel.level1:
          return _viewDisplayedOfAccountMenuItem();
      }
    });
  }

  Widget _viewDisplayedOfAccountMenuItem() {
    return Obx(() {
      switch(controller.manageAccountDashboardController.accountMenuItemSelected.value) {
        case AccountMenuItem.profiles:
          return ProfilesView();
        case AccountMenuItem.languageAndRegion:
          return LanguageAndRegionView();
        case AccountMenuItem.emailRules:
          if (controller.manageAccountDashboardController.isRuleFilterCapabilitySupported) {
            return EmailRulesView();
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
        default:
          return const SizedBox.shrink();
      }
    });
  }
}