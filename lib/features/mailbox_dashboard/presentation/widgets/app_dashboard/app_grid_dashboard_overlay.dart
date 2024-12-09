import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/app_grid_dashboard_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/app_dashboard/app_grid_dashboard_item.dart';

class AppDashboardOverlay extends StatelessWidget {
  final List<AppLinagoraEcosystem> listLinagoraApp;
  final ImagePaths imagePaths;

  const AppDashboardOverlay({
    Key? key,
    required this.listLinagoraApp,
    required this.imagePaths,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        width: _widthAppGrid,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppGridDashboardStyle.cardShadow
        ),
        padding: AppGridDashboardStyle.padding,
        child: Wrap(children: listLinagoraApp
          .map((app) => AppGridDashboardItem(app: app, imagePaths: imagePaths))
          .toList()),
      ),
    );
  }

  double get _widthAppGrid {
    if (listLinagoraApp.length >= 3) {
      return AppGridDashboardStyle.hoverIconSize * 3 + AppGridDashboardStyle.padding.horizontal;
    } else if (listLinagoraApp.length == 2) {
      return AppGridDashboardStyle.hoverIconSize * 2 + AppGridDashboardStyle.padding.horizontal;
    } else {
      return AppGridDashboardStyle.hoverIconSize + AppGridDashboardStyle.padding.horizontal;
    }
  }
}
