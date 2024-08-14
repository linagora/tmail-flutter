import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/app_dashboard/app_grid_dashboard_overlay.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class AppGridDashboardIcon extends StatelessWidget {

  final ImagePaths _imagePaths = Get.find<ImagePaths>();

  final AppGridDashboardController appGridController;
  final VoidCallback? onShowAppDashboardAction;

  AppGridDashboardIcon({
    super.key,
    required this.appGridController,
    this.onShowAppDashboardAction
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAppGridOpen = appGridController.isAppGridDashboardOverlayOpen.value;
      return PortalTarget(
        visible: isAppGridOpen,
        portalFollower: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: appGridController.toggleAppGridDashboard
        ),
        child: PortalTarget(
          anchor: Aligned(
            follower: AppUtils.isDirectionRTL(context)
              ? Alignment.topLeft
              : Alignment.topRight,
            target: AppUtils.isDirectionRTL(context)
              ? Alignment.bottomLeft
              : Alignment.bottomRight
          ),
          portalFollower: Obx(() {
            final listApps = appGridController.linagoraApplications.value;
            if (listApps?.apps.isNotEmpty == true) {
              return AppDashboardOverlay(listApps!);
            }
            return const SizedBox.shrink();
          }),
          visible: isAppGridOpen,
          child: TMailButtonWidget.fromIcon(
            icon: _imagePaths.icAppDashboard,
            backgroundColor: Colors.transparent,
            iconSize: 30,
            padding: const EdgeInsets.all(6),
            onTapActionCallback: onShowAppDashboardAction,
          ),
        )
      );
    });
  }
}
