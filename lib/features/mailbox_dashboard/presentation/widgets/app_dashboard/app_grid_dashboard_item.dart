import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/image/image_loader_mixin.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/launcher_application_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/link_browser_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/app_grid_dashboard_style.dart';

class AppGridDashboardItem extends StatelessWidget
    with LauncherApplicationMixin, ImageLoaderMixin {

  final AppLinagoraEcosystem app;
  final ImagePaths imagePaths;

  const AppGridDashboardItem({
    Key? key,
    required this.app,
    required this.imagePaths,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LinkBrowserWidget(
      uri: app.appRedirectLink!,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => launchApplication(uri: app.appRedirectLink),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          hoverColor: AppColor.colorBgMailboxSelected,
          child: Container(
            width: AppGridDashboardStyle.hoverIconSize,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(children: [
              if (app.getIconPath(imagePaths) != null)
                buildImage(
                  imagePath: app.getIconPath(imagePaths)!,
                  imageSize: AppGridDashboardStyle.iconSize,
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  app.appName ?? '',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ]),
          ),
        )
      )
    );
  }
}
