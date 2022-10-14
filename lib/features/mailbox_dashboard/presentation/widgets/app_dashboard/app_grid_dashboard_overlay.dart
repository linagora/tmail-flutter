import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/list/sliver_grid_delegate_fixed_height.dart';
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
        width: 342,
        height: 244,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColor.colorShadowComposer,
              blurRadius: 32,
              offset: Offset.zero),
            BoxShadow(
              color: AppColor.colorDropShadow,
              blurRadius: 4,
              offset: Offset.zero),
          ]
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(24),
          itemBuilder: (context, i) {
            final app = _linagoraApplications.apps[i];
            return AppGridDashboardItem(app);
          },
          primary: true,
          itemCount: _linagoraApplications.apps.length,
          gridDelegate: const SliverGridDelegateFixedHeight(
            height: 98,
            crossAxisCount: 3,
          ),
        ),
      ),
    );
  }
}
