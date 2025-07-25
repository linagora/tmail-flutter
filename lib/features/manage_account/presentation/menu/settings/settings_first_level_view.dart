import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/widgets/setting_first_level_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class SettingsFirstLevelView extends GetWidget<SettingsController> {
  const SettingsFirstLevelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('setting_menu'),
      child: Column(children: [
        Obx(() => UserInformationWidget(
          ownEmailAddress: controller
            .manageAccountDashboardController
            .ownEmailAddress
            .value,
          padding: SettingsUtils.getPaddingInFirstLevel(
            context,
            controller.responsiveUtils,
          ),
          titlePadding: const EdgeInsetsDirectional.only(start: 16),
        )),
        Divider(
          color: AppColor.colorDividerHorizontal,
          height: 1,
          indent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils),
          endIndent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils)
        ),
        SettingFirstLevelTileBuilder(
          AppLocalizations.of(context).profiles,
          AccountMenuItem.profiles.getIcon(controller.imagePaths),
          subtitle: AppLocalizations.of(context).profilesSettingExplanation,
          () => controller.selectSettings(AccountMenuItem.profiles)
        ),
        Divider(
          color: AppColor.colorDividerHorizontal,
          height: 1,
          indent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils),
          endIndent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils)
        ),
        Obx(() {
          if (controller.manageAccountDashboardController.isRuleFilterCapabilitySupported) {
            return Column(children: [
              SettingFirstLevelTileBuilder(
                AccountMenuItem.emailRules.getName(AppLocalizations.of(context)),
                AccountMenuItem.emailRules.getIcon(controller.imagePaths),
                subtitle: AppLocalizations.of(context).emailRuleSettingExplanation,
                () => controller.selectSettings(AccountMenuItem.emailRules)
              ),
              Divider(
                color: AppColor.colorDividerHorizontal,
                height: 1,
                indent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils),
                endIndent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils)
              ),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.manageAccountDashboardController.isServerSettingsCapabilitySupported) {
            return Column(children: [
              SettingFirstLevelTileBuilder(
                AccountMenuItem.preferences.getName(AppLocalizations.of(context)),
                AccountMenuItem.preferences.getIcon(controller.imagePaths),
                subtitle: AppLocalizations.of(context).emailReadReceiptsSettingExplanation,
                () => controller.selectSettings(AccountMenuItem.preferences)
              ),
              Divider(
                color: AppColor.colorDividerHorizontal,
                height: 1,
                indent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils),
                endIndent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils)
              ),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.manageAccountDashboardController.isForwardCapabilitySupported) {
            return Column(children: [
              SettingFirstLevelTileBuilder(
                AccountMenuItem.forward.getName(AppLocalizations.of(context)),
                AccountMenuItem.forward.getIcon(controller.imagePaths),
                subtitle: AppLocalizations.of(context).forwardingSettingExplanation,
                () => controller.selectSettings(AccountMenuItem.forward)
              ),
              Divider(
                color: AppColor.colorDividerHorizontal,
                height: 1,
                indent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils),
                endIndent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils)
              ),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.manageAccountDashboardController.isVacationCapabilitySupported) {
            return Column(children: [
              SettingFirstLevelTileBuilder(
                AccountMenuItem.vacation.getName(AppLocalizations.of(context)),
                AccountMenuItem.vacation.getIcon(controller.imagePaths),
                subtitle: AppLocalizations.of(context).vacationSettingExplanation,
                () => controller.selectSettings(AccountMenuItem.vacation)
              ),
              Divider(
                color: AppColor.colorDividerHorizontal,
                height: 1,
                indent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils),
                endIndent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils)
              ),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        }),
        SettingFirstLevelTileBuilder(
          AccountMenuItem.mailboxVisibility.getName(AppLocalizations.of(context)),
          AccountMenuItem.mailboxVisibility.getIcon(controller.imagePaths),
          subtitle: AppLocalizations.of(context).folderVisibilitySubtitle,
          () => controller.selectSettings(AccountMenuItem.mailboxVisibility)
        ),
        Obx(() {
          if (!controller.manageAccountDashboardController.isLanguageSettingDisplayed) {
            return const SizedBox.shrink();
          }

          return Column(children: [
            Divider(
              color: AppColor.colorDividerHorizontal,
              height: 1,
              indent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils),
              endIndent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils)
            ),
            SettingFirstLevelTileBuilder(
              key: const Key('setting_language_region'),
              AccountMenuItem.languageAndRegion.getName(AppLocalizations.of(context)),
              AccountMenuItem.languageAndRegion.getIcon(controller.imagePaths),
              () => controller.selectSettings(AccountMenuItem.languageAndRegion)
            ),
          ]);
        }),
        Obx(() {
          if (controller.manageAccountDashboardController.isFcmCapabilitySupported && PlatformInfo.isMobile) {
            return Column(children: [
              Divider(
                  color: AppColor.colorDividerHorizontal,
                  height: 1,
                  indent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils),
                  endIndent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils)
              ),
              SettingFirstLevelTileBuilder(
                AppLocalizations.of(context).notification,
                controller.imagePaths.icNotification,
                    () => controller.selectSettings(AccountMenuItem.notification),
                subtitle: AppLocalizations.of(context).allowsTwakeMailToNotifyYouWhenANewMessageArrivesOnYourPhone,
              )
            ]);
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          final accountId = controller
            .manageAccountDashboardController
            .accountId
            .value;

          if (accountId == null) return const SizedBox.shrink();

          final contactSupportCapability = controller
            .manageAccountDashboardController
            .sessionCurrent
            ?.getContactSupportCapability(accountId);

          if (contactSupportCapability?.isAvailable != true) return const SizedBox.shrink();

          return Column(children: [
            Divider(
              color: AppColor.colorDividerHorizontal,
              height: 1,
              indent: SettingsUtils.getHorizontalPadding(
                context,
                controller.responsiveUtils,
              ),
              endIndent: SettingsUtils.getHorizontalPadding(
                context,
                controller.responsiveUtils,
              ),
            ),
            SettingFirstLevelTileBuilder(
              AccountMenuItem.contactSupport.getName(AppLocalizations.of(context)),
              AccountMenuItem.contactSupport.getIcon(controller.imagePaths),
              () => controller.onGetHelpOrReportBug(
                contactSupportCapability!,
                route: AppRoutes.settings,
              ),
            ),
          ]);
        }),
        Divider(
          color: AppColor.colorDividerHorizontal,
          height: 1,
          indent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils),
          endIndent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils)
        ),
        SettingFirstLevelTileBuilder(
          AppLocalizations.of(context).sign_out,
          controller.imagePaths.icSignOut,
          () => controller.manageAccountDashboardController.logout(
              context,
              controller.manageAccountDashboardController.sessionCurrent,
              controller.manageAccountDashboardController.accountId.value)
        ),
      ]),
    );
  }
}
