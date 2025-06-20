import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/button/multi_click_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/export_trace_log_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/mailbox_visibility_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_first_level_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/notification/notification_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/preferences_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

typedef CloseSettingsViewAction = void Function();

class SettingsView extends GetWidget<SettingsController> {
  const SettingsView({Key? key, this.closeAction}) : super(key: key);

  final CloseSettingsViewAction? closeAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox.fromSize(
          size: const Size.fromHeight(52),
          child: Padding(
            padding: SettingsUtils.getPaddingAppBar(context, controller.responsiveUtils),
            child: _buildAppbar(context))),
        const Divider(color: AppColor.colorDividerComposer, height: 1),
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
    final appBarWidget = Stack(
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );

    if (AppConfig.isApiLoggingEnabled) {
      return MultiClickWidget(
        onMultiTap: () => controller
          .manageAccountDashboardController
          .showExportTraceLogConfirmDialog(context),
        child: appBarWidget,
      );
    } else {
      return appBarWidget;
    }
  }

  Widget _buildSettingLevel1AppBar(BuildContext context) {
    return Row(children: [
      Material(
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
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                SvgPicture.asset(
                  DirectionUtils.isDirectionRTLByLanguage(context)
                    ? controller.imagePaths.icCollapseFolder
                    : controller.imagePaths.icBack,
                  colorFilter: AppColor.colorTextButton.asFilter(),
                  fit: BoxFit.fill),
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 4),
                  constraints: const BoxConstraints(maxWidth: 80),
                  child: Text(
                    AppLocalizations.of(context).settings,
                    maxLines: 1,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    style: const TextStyle(fontSize: 17, color: AppColor.colorTextButton)
                  )
                ),
              ]),
            ),
          ),
        ),
      ),
      Expanded(child: Text(
        controller.manageAccountDashboardController.accountMenuItemSelected.value.getName(AppLocalizations.of(context)),
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: CommonTextStyle.defaultTextOverFlow,
        softWrap: CommonTextStyle.defaultSoftWrap,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.black,
          fontWeight: FontWeight.bold
        )
      )),
      Container(constraints: const BoxConstraints(maxWidth: 80))
    ]);
  }

  Widget _buildCloseSettingButton(BuildContext context) {
    return buildIconWeb(
      icon: SvgPicture.asset(controller.imagePaths.icClose, width: 28, height: 28, fit: BoxFit.fill),
      tooltip: AppLocalizations.of(context).close,
      onTap: closeAction);
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