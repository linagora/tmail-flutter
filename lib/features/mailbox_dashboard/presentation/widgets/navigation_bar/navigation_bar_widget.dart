import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/support/contact_support_capability.dart';
import 'package:tmail_ui_user/features/base/mixin/contact_support_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/application_logo_with_text_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/navigation_bar_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/app_dashboard/app_grid_dashboard_icon.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class NavigationBarWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final AccountId? accountId;
  final String avatarUserName;
  final ContactSupportCapability? contactSupportCapability;
  final Widget? searchForm;
  final AppGridDashboardController? appGridController;
  final VoidCallback? onTapApplicationLogoAction;
  final OnTapAvatarActionWithPositionClick? onTapAvatarAction;
  final OnTapContactSupportAction? onTapContactSupportAction;

  const NavigationBarWidget({
    super.key,
    required this.imagePaths,
    required this.accountId,
    required this.avatarUserName,
    this.contactSupportCapability,
    this.searchForm,
    this.appGridController,
    this.onTapApplicationLogoAction,
    this.onTapAvatarAction,
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
                  width: constraint.maxWidth / 2,
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
                if (accountId != null)
                  (AvatarBuilder()
                    ..text(avatarUserName)
                    ..backgroundColor(Colors.white)
                    ..textColor(Colors.black)
                    ..context(context)
                    ..size(48)
                    ..addOnTapAvatarActionWithPositionClick(onTapAvatarAction)
                    ..addBoxShadows([
                      const BoxShadow(
                        color: AppColor.colorShadowBgContentEmail,
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 0.5)
                      )
                    ])
                  ).build()
              ]
            );
          }))
        else
          ...[
            const Spacer(),
            if (contactSupportCapability != null)
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
            if (accountId != null)
              (AvatarBuilder()
                ..text(avatarUserName)
                ..backgroundColor(Colors.white)
                ..textColor(Colors.black)
                ..context(context)
                ..size(48)
                ..addOnTapAvatarActionWithPositionClick(onTapAvatarAction)
                ..addBoxShadows([
                  const BoxShadow(
                    color: AppColor.colorShadowBgContentEmail,
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 0.5)
                  )
                ])
              ).build()
          ]
      ]),
    );
  }
}
