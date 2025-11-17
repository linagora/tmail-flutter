import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/setting_user_info_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/widgets/setting_first_level_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class SettingsFirstLevelView extends GetWidget<SettingsController> {
  const SettingsFirstLevelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final indent = SettingsUtils.getHorizontalPadding(
      context,
      controller.responsiveUtils,
    );

    final appLocalizations = AppLocalizations.of(context);

    final divider = Divider(
      color: AppColor.colorDividerHorizontal,
      height: 1,
      indent: indent,
      endIndent: indent,
    );

    return SingleChildScrollView(
      key: const Key('setting_menu'),
      child: Column(children: [
        Obx(() {
          String ownEmailAddress = controller
            .manageAccountDashboardController
            .ownEmailAddress
            .value;

          if (ownEmailAddress.trim().isEmpty) {
            ownEmailAddress = controller
              .manageAccountDashboardController
              .sessionCurrent
              ?.getOwnEmailAddressOrUsername() ?? '';
          }

          if (PlatformInfo.isMobile) {
            final ownDisplayName = controller
              .manageAccountDashboardController
              .sessionCurrent
              ?.getUserDisplayName() ?? '';

            final oidcUserInfo = controller
              .manageAccountDashboardController
              .twakeAppManager
              .oidcUserInfo;

            return SettingUserInfoWidget(
              ownEmailAddress: ownEmailAddress,
              ownDisplayName: ownDisplayName,
              imagePaths: controller.imagePaths,
              oidcUserInfo: oidcUserInfo,
              onOpenCommonSetting: controller.goToCommonSetting,
            );
          } else {
            return UserInformationWidget(
              ownEmailAddress: ownEmailAddress,
              padding: SettingsUtils.getPaddingInFirstLevel(
                context,
                controller.responsiveUtils,
              ),
              titlePadding: const EdgeInsetsDirectional.only(start: 16),
            );
          }
        }),
        divider,
        _buildSettingItem(
          key: const Key('setting_profiles'),
          context: context,
          menuItem: AccountMenuItem.profiles,
          appLocalizations: appLocalizations,
        ),
        divider,
        Obx(() {
          if (controller.manageAccountDashboardController.isRuleFilterCapabilitySupported) {
            return Column(children: [
              _buildSettingItem(
                context: context,
                menuItem: AccountMenuItem.emailRules,
                appLocalizations: appLocalizations,
              ),
              divider,
            ]);
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.manageAccountDashboardController.isServerSettingsCapabilitySupported) {
            return Column(children: [
              _buildSettingItem(
                key: const ValueKey('setting_preferences'),
                context: context,
                menuItem: AccountMenuItem.preferences,
                appLocalizations: appLocalizations,
              ),
              divider,
            ]);
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.manageAccountDashboardController.isForwardCapabilitySupported) {
            return Column(children: [
              _buildSettingItem(
                context: context,
                menuItem: AccountMenuItem.forward,
                appLocalizations: appLocalizations,
              ),
              divider,
            ]);
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.manageAccountDashboardController.isVacationCapabilitySupported) {
            return Column(children: [
              _buildSettingItem(
                context: context,
                menuItem: AccountMenuItem.vacation,
                appLocalizations: appLocalizations,
              ),
              divider,
            ]);
          } else {
            return const SizedBox.shrink();
          }
        }),
        _buildSettingItem(
          context: context,
          menuItem: AccountMenuItem.mailboxVisibility,
          appLocalizations: appLocalizations,
        ),
        Obx(() {
          if (!controller.manageAccountDashboardController.isLanguageSettingDisplayed) {
            return const SizedBox.shrink();
          }

          return Column(children: [
            divider,
            _buildSettingItem(
              key: const Key('setting_language_region'),
              context: context,
              menuItem: AccountMenuItem.languageAndRegion,
              appLocalizations: appLocalizations,
            ),
          ]);
        }),
        if (PlatformInfo.isWeb)
          ...[
            divider,
            _buildSettingItem(
              context: context,
              menuItem: AccountMenuItem.keyboardShortcuts,
              appLocalizations: appLocalizations,
            ),
          ],
        Obx(() {
          final octetsQuota = controller
              .manageAccountDashboardController
              .octetsQuota
              .value;

          if (octetsQuota != null && octetsQuota.storageAvailable) {
            return Column(children: [
              divider,
              _buildSettingItem(
                context: context,
                menuItem: AccountMenuItem.storage,
                appLocalizations: appLocalizations,
              ),
            ]);
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.manageAccountDashboardController.isFcmCapabilitySupported && PlatformInfo.isMobile) {
            return Column(children: [
              divider,
              _buildSettingItem(
                context: context,
                menuItem: AccountMenuItem.notification,
                appLocalizations: appLocalizations,
              ),
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
            divider,
            _buildSettingItem(
              context: context,
              menuItem: AccountMenuItem.contactSupport,
              appLocalizations: appLocalizations,
              onActionCallback: () => controller.onGetHelpOrReportBug(
                contactSupportCapability!,
                route: AppRoutes.settings,
              ),
            ),
          ]);
        }),
        divider,
        _buildSettingItem(
          context: context,
          menuItem: AccountMenuItem.signOut,
          appLocalizations: appLocalizations,
        ),
      ]),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required AccountMenuItem menuItem,
    required AppLocalizations appLocalizations,
    Key? key,
    VoidCallback? onActionCallback,
  }) {
    return SettingFirstLevelTileBuilder(
      key: key,
      menuItem.getName(appLocalizations),
      menuItem.getIcon(controller.imagePaths),
      subtitle: menuItem.getExplanation(appLocalizations),
      onActionCallback ?? () => controller.selectSettings(context, menuItem),
    );
  }
}
