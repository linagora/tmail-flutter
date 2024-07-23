import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/link_browser_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_app.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/app_grid_dashboard_style.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class AppGridDashboardItem extends StatelessWidget {
  final LinagoraApp app;

  AppGridDashboardItem(this.app, {Key? key}) : super(key: key);

  final ImagePaths _imagePaths = Get.find<ImagePaths>();

  @override
  Widget build(BuildContext context) {
    return LinkBrowserWidget(
      uri: app.appUri,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AppUtils.launchLink(app.appUri.toString()),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          hoverColor: AppColor.colorBgMailboxSelected,
          child: Container(
            width: AppGridDashboardStyle.hoverIconSize,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(children: [
              if (app.iconName?.isNotEmpty == true)
                app.iconName!.endsWith("svg")
                  ? SvgPicture.asset(
                      _imagePaths.getConfigurationImagePath(app.iconName!),
                      width: AppGridDashboardStyle.iconSize,
                      height: AppGridDashboardStyle.iconSize,
                      fit: BoxFit.fill)
                  : Image.asset(
                      _imagePaths.getConfigurationImagePath(app.iconName!),
                      width: AppGridDashboardStyle.iconSize,
                      height: AppGridDashboardStyle.iconSize,
                      fit: BoxFit.fill)
              else if (app.publicIconUri != null)
                Image.network(
                  app.publicIconUri.toString(),
                  width: AppGridDashboardStyle.iconSize,
                  height: AppGridDashboardStyle.iconSize,
                  fit: BoxFit.fill,
                  errorBuilder: (_, error, stackTrace) {
                    return Container(
                      width: AppGridDashboardStyle.iconSize,
                      height: AppGridDashboardStyle.iconSize,
                      color: AppColor.textFieldHintColor,
                    );
                  }
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  app.appName,
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
