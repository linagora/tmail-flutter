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
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_first_level_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef CloseSettingsViewAction = void Function();

class SettingsView extends GetWidget<SettingsController> {
  SettingsView({Key? key, this.closeAction}) : super(key: key);

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();
  final CloseSettingsViewAction? closeAction;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox.fromSize(
            size: const Size.fromHeight(52),
            child: Padding(
              padding: SettingsUtils.getPaddingInFirstLevel(context, _responsiveUtils),
              child: _buildAppbar(context))),
          const Divider(color: AppColor.colorDividerComposer, height: 1),
          Obx(() {
            if (controller.manageAccountDashboardController.vacationResponse.value?.vacationResponderIsValid == true) {
              return VacationNotificationMessageWidget(
                margin: const EdgeInsets.only(
                  left: BuildUtils.isWeb ? 24 : 16,
                  right: BuildUtils.isWeb ? 24 : 16,
                  top: 16),
                vacationResponse: controller.manageAccountDashboardController.vacationResponse.value!,
                action: () => controller.manageAccountDashboardController.disableVacationResponder());
            } else if ((controller.manageAccountDashboardController.vacationResponse.value?.vacationResponderIsWaiting == true
                || controller.manageAccountDashboardController.vacationResponse.value?.vacationResponderIsStopped == true)
                && controller.manageAccountDashboardController.inVacationSettings()) {
              return VacationNotificationMessageWidget(
                  margin: const EdgeInsets.only(
                    left: BuildUtils.isWeb ? 24 : 16,
                    right: BuildUtils.isWeb ? 24 : 16,
                    top: 16),
                  vacationResponse: controller.manageAccountDashboardController.vacationResponse.value!,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  fontWeight: FontWeight.normal,
                  backgroundColor: Colors.yellow,
                  leadingIcon: const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.timer, size: 20),
                  ));
            } else {
              return const SizedBox.shrink();
            }
          }),
          Expanded(child: Padding(
            padding: !BuildUtils.isWeb && _responsiveUtils.isPortraitMobile(context)
              ? const EdgeInsets.only(left: 8)
              : const EdgeInsets.only(left: 24),
            child: _bodySettingsScreen()))
        ]
      )
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
    return Row(children: [
      _buildBackButton(context),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          AppLocalizations.of(context).settings,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 21, color: Colors.black, fontWeight: FontWeight.bold)
        )
      )
    ]);
  }

  Widget _buildBackButton(BuildContext context) {
    return buildIconWeb(
        icon: SvgPicture.asset(_imagePaths.icBack, width: 18, height: 18, color: AppColor.colorTextButton, fit: BoxFit.fill),
        tooltip: AppLocalizations.of(context).back,
        onTap: controller.backToUniversalSettings
    );
  }

  Widget _buildCloseSettingButton(BuildContext context) {
    return buildIconWeb(
      icon: SvgPicture.asset(_imagePaths.icCloseMailbox, width: 28, height: 28, fit: BoxFit.fill),
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
          if(controller.manageAccountDashboardController.checkAvailableRuleFilterInSession()){
            return EmailRulesView();
          } else {
            return const SizedBox.shrink();
          }
        case AccountMenuItem.forward:
          if(controller.manageAccountDashboardController.checkAvailableForwardInSession()){
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