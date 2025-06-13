import 'dart:math';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/support/contact_support_capability.dart';
import 'package:tmail_ui_user/features/base/mixin/contact_support_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/application_logo_with_text_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/navigation_bar_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/app_dashboard/app_grid_dashboard_icon.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/profile_setting/profile_setting_icon.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/profile_setting/profile_setting_menu_overlay.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class NavigationBarWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final AccountId? accountId;
  final String ownEmailAddress;
  final ContactSupportCapability? contactSupportCapability;
  final Widget? searchForm;
  final AppGridDashboardController? appGridController;
  final List<ProfileSettingActionType> settingActionTypes;
  final VoidCallback? onTapApplicationLogoAction;
  final OnTapContactSupportAction? onTapContactSupportAction;
  final OnProfileSettingActionTypeClick onProfileSettingActionTypeClick;

  const NavigationBarWidget({
    super.key,
    required this.imagePaths,
    required this.accountId,
    required this.ownEmailAddress,
    required this.onProfileSettingActionTypeClick,
    this.contactSupportCapability,
    this.searchForm,
    this.appGridController,
    this.settingActionTypes = const [],
    this.onTapApplicationLogoAction,
    this.onTapContactSupportAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: NavigationBarStyle.barHeight,
      color: Colors.white,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: NavigationBarStyle.horizontalMargin),
      child: Row(children: [
        SizedBox(
          width: ResponsiveUtils.defaultSizeMenu - NavigationBarStyle.horizontalMargin,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ApplicationLogoWidthTextWidget(onTapAction: onTapApplicationLogoAction),
              const Spacer(),
            ],
          ),
        ),
        if (searchForm != null)
          Expanded(child: LayoutBuilder(builder: (context, constraint) {
            return Row(
              children: [
                SizedBox(
                  width: min(
                    max(constraint.maxWidth / 2, 576),
                    constraint.maxWidth,
                  ),
                  height: 52,
                  child: searchForm
                ),
                const Spacer(),
                if (contactSupportCapability?.isAvailable == true)
                  TMailButtonWidget.fromIcon(
                    icon: imagePaths.icHelp,
                    iconColor: AppColor.messageDialogColor,
                    backgroundColor: Colors.transparent,
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    tooltipMessage: AppLocalizations.of(context).getHelpOrReportABug,
                    onTapActionCallback: () => onTapContactSupportAction?.call(contactSupportCapability!),
                  ),
                if (appGridController != null)
                  Obx(() {
                    if (appGridController!.listLinagoraApp.isNotEmpty) {
                      return AppGridDashboardIcon(
                        imagePaths: imagePaths,
                        linagoraApps: appGridController!.listLinagoraApp,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                const SizedBox(width: 16),
                ProfileSettingIcon(
                  ownEmailAddress: ownEmailAddress,
                  settingActionTypes: settingActionTypes,
                  onProfileSettingActionTypeClick: onProfileSettingActionTypeClick,
                ),
              ]
            );
          }))
        else
          ...[
            const Spacer(),
            if (contactSupportCapability?.isAvailable == true)
              TMailButtonWidget.fromIcon(
                icon: imagePaths.icHelp,
                iconColor: AppColor.messageDialogColor,
                backgroundColor: Colors.transparent,
                margin: const EdgeInsetsDirectional.only(end: 8),
                tooltipMessage: AppLocalizations.of(context).getHelpOrReportABug,
                onTapActionCallback: () => onTapContactSupportAction?.call(contactSupportCapability!),
              ),
            if (appGridController != null)
              Obx(() {
                if (appGridController!.listLinagoraApp.isNotEmpty) {
                  return AppGridDashboardIcon(
                    imagePaths: imagePaths,
                    linagoraApps: appGridController!.listLinagoraApp,
                  );
                }
                return const SizedBox.shrink();
              }),
            const SizedBox(width: 16),
            ProfileSettingIcon(
              ownEmailAddress: ownEmailAddress,
              settingActionTypes: settingActionTypes,
              onProfileSettingActionTypeClick: onProfileSettingActionTypeClick,
            ),
          ]
      ]),
    );
  }
}
