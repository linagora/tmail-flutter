import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_applications.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/app_grid_dashboard_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/app_dashboard/app_grid_dashboard_item.dart';

class AppDashboardOverlay extends StatelessWidget {
  final LinagoraApplications _linagoraApplications;

  const AppDashboardOverlay(this._linagoraApplications, {Key? key}) : super(key: key);

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
        child: Wrap(children: _linagoraApplications.apps
          .map((app) => AppGridDashboardItem(app))
          .toList()),
      ),
    );
  }

  double get _widthAppGrid {
    if (_linagoraApplications.apps.length >= 3) {
      return AppGridDashboardStyle.hoverIconSize * 3 + AppGridDashboardStyle.padding.horizontal;
    } else if (_linagoraApplications.apps.length == 2) {
      return AppGridDashboardStyle.hoverIconSize * 2 + AppGridDashboardStyle.padding.horizontal;
    } else {
      return AppGridDashboardStyle.hoverIconSize + AppGridDashboardStyle.padding.horizontal;
    }
  }
}
