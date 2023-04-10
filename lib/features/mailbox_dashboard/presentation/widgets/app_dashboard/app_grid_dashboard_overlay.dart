import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_applications.dart';
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
          boxShadow: const [
            BoxShadow(
              color: AppColor.colorShadowLayerBottom,
              blurRadius: 96,
              offset: Offset.zero),
            BoxShadow(
              color: AppColor.colorShadowLayerTop,
              blurRadius: 2,
              offset: Offset.zero),
          ]
        ),
        padding: const EdgeInsets.all(24),
        child: Wrap(children: _linagoraApplications.apps
          .map((app) => AppGridDashboardItem(app))
          .toList()),
      ),
    );
  }

  double get _widthAppGrid {
    if (_linagoraApplications.apps.length >= 3) {
      return 342;
    } else if (_linagoraApplications.apps.length == 2) {
      return 244;
    } else if (_linagoraApplications.apps.length == 1) {
      return 146;
    } else {
      return 0;
    }
  }
}
