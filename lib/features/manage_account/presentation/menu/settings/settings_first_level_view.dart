import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/widgets/setting_first_level_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SettingsFirstLevelView extends GetWidget<SettingsController> {
  const SettingsFirstLevelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = SingleChildScrollView(
      controller: PlatformInfo.isMobile ? null : controller.settingScrollController,
      child: Column(children: [
        Obx(() => UserInformationWidget(
          userProfile: controller.manageAccountDashboardController.userProfile.value,
          padding: SettingsUtils.getPaddingInFirstLevel(context, controller.responsiveUtils),
          titlePadding: const EdgeInsetsDirectional.only(start: 16))),
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
                AccountMenuItem.emailRules.getName(context),
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
                AccountMenuItem.alwaysReadReceipt.getName(context),
                AccountMenuItem.alwaysReadReceipt.getIcon(controller.imagePaths),
                subtitle: AppLocalizations.of(context).emailReadReceiptsSettingExplanation,
                () => controller.selectSettings(AccountMenuItem.alwaysReadReceipt)
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
                AccountMenuItem.forward.getName(context),
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
                AccountMenuItem.vacation.getName(context),
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
        Column(children: [
          SettingFirstLevelTileBuilder(
            AccountMenuItem.mailboxVisibility.getName(context),
            AccountMenuItem.mailboxVisibility.getIcon(controller.imagePaths),
            subtitle: AppLocalizations.of(context).folderVisibilitySubtitle,
            () => controller.selectSettings(AccountMenuItem.mailboxVisibility)
          ),
          Divider(
            color: AppColor.colorDividerHorizontal,
            height: 1,
            indent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils),
            endIndent: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils)
          ),
        ]),
        SettingFirstLevelTileBuilder(
          AccountMenuItem.languageAndRegion.getName(context),
          AccountMenuItem.languageAndRegion.getIcon(controller.imagePaths),
          () => controller.selectSettings(AccountMenuItem.languageAndRegion)
        ),
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
              controller.manageAccountDashboardController.sessionCurrent,
              controller.manageAccountDashboardController.accountId.value)
        ),
      ]),
    );

    if (PlatformInfo.isMobile) {
      return child;
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ScrollbarListView(
          scrollController: controller.settingScrollController,
          child: child
        ),
      );
    }
  }
}
