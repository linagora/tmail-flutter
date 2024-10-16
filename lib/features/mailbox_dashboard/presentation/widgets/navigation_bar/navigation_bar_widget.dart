import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/application_logo_with_text_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/navigation_bar_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/app_dashboard/app_grid_dashboard_icon.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class NavigationBarWidget extends StatelessWidget {

  final String avatarUserName;
  final Widget? searchForm;
  final AppGridDashboardController? appGridController;
  final VoidCallback? onTapApplicationLogoAction;
  final VoidCallback? onShowAppDashboardAction;
  final OnTapAvatarActionWithPositionClick? onTapAvatarAction;

  const NavigationBarWidget({
    super.key,
    required this.avatarUserName,
    this.searchForm,
    this.appGridController,
    this.onShowAppDashboardAction,
    this.onTapApplicationLogoAction,
    this.onTapAvatarAction,
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
                if (AppConfig.appGridDashboardAvailable && appGridController != null)
                  AppGridDashboardIcon(
                    appGridController: appGridController!,
                    onShowAppDashboardAction: onShowAppDashboardAction,
                  ),
                const SizedBox(width: 16),
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
            if (AppConfig.appGridDashboardAvailable && appGridController != null)
              AppGridDashboardIcon(
                appGridController: appGridController!,
                onShowAppDashboardAction: onShowAppDashboardAction,
              ),
            const SizedBox(width: 16),
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
