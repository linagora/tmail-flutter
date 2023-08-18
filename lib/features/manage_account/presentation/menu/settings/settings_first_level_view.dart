import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/widgets/setting_first_level_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SettingsFirstLevelView extends GetWidget<SettingsController> {
  SettingsFirstLevelView({Key? key}) : super(key: key);

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Obx(() => UserInformationWidget(
          userProfile: controller.manageAccountDashboardController.userProfile.value,
          padding: SettingsUtils.getPaddingInFirstLevel(context, _responsiveUtils),
          titlePadding: const EdgeInsetsDirectional.only(start: 16))),
        Divider(
          color: AppColor.colorDividerComposer,
          height: 1,
          indent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils),
          endIndent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils)
        ),
        SettingFirstLevelTileBuilder(
          AppLocalizations.of(context).profiles,
          AccountMenuItem.profiles.getIcon(_imagePaths),
          subtitle: AppLocalizations.of(context).profilesSettingExplanation,
          () => controller.selectSettings(AccountMenuItem.profiles)
        ),
        Divider(
          color: AppColor.colorDividerComposer,
          height: 1,
          indent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils),
          endIndent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils)
        ),
        Obx(() {
          if (controller.manageAccountDashboardController.isRuleFilterCapabilitySupported) {
            return Column(children: [
              SettingFirstLevelTileBuilder(
                AccountMenuItem.emailRules.getName(context),
                AccountMenuItem.emailRules.getIcon(_imagePaths),
                subtitle: AppLocalizations.of(context).emailRuleSettingExplanation,
                () => controller.selectSettings(AccountMenuItem.emailRules)
              ),
              Divider(
                color: AppColor.colorDividerComposer,
                height: 1,
                indent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils),
                endIndent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils)
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
                AccountMenuItem.forward.getIcon(_imagePaths),
                subtitle: AppLocalizations.of(context).forwardingSettingExplanation,
                () => controller.selectSettings(AccountMenuItem.forward)
              ),
              Divider(
                color: AppColor.colorDividerComposer,
                height: 1,
                indent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils),
                endIndent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils)
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
                AccountMenuItem.vacation.getIcon(_imagePaths),
                subtitle: AppLocalizations.of(context).vacationSettingExplanation,
                () => controller.selectSettings(AccountMenuItem.vacation)
              ),
              Divider(
                color: AppColor.colorDividerComposer,
                height: 1,
                indent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils),
                endIndent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils)
              ),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        }),
        Column(children: [
          SettingFirstLevelTileBuilder(
            AccountMenuItem.mailboxVisibility.getName(context),
            AccountMenuItem.mailboxVisibility.getIcon(_imagePaths),
            subtitle: AppLocalizations.of(context).mailboxVisibilitySubtitle,
            () => controller.selectSettings(AccountMenuItem.mailboxVisibility)
          ),
          Divider(
            color: AppColor.colorDividerComposer,
            height: 1,
            indent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils),
            endIndent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils)
          ),
        ]),
        SettingFirstLevelTileBuilder(
          AccountMenuItem.languageAndRegion.getName(context),
          AccountMenuItem.languageAndRegion.getIcon(_imagePaths),
          () => controller.selectSettings(AccountMenuItem.languageAndRegion)
        ),
        Divider(
          color: AppColor.colorDividerComposer,
          height: 1,
          indent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils),
          endIndent: SettingsUtils.getHorizontalPadding(context, _responsiveUtils)
        ),
        SettingFirstLevelTileBuilder(
          AppLocalizations.of(context).sign_out,
          _imagePaths.icSignOut,
          () => controller.manageAccountDashboardController.logout(
              controller.manageAccountDashboardController.sessionCurrent,
              controller.manageAccountDashboardController.accountId.value)
        ),
      ]),
    );
  }
}
