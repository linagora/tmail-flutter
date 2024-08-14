import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/app_dashboard/app_grid_dashboard_overlay.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class AppGridDashboardIcon extends StatefulWidget {

  final ImagePaths imagePaths;
  final List<AppLinagoraEcosystem> linagoraApps;

  const AppGridDashboardIcon({
    super.key,
    required this.imagePaths,
    required this.linagoraApps,
  });

  @override
  State<AppGridDashboardIcon> createState() => _AppGridDashboardIconState();
}

class _AppGridDashboardIconState extends State<AppGridDashboardIcon> {

  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isExpandedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isExpandedNotifier,
      builder: (context, isExpanded, child) {
        return PortalTarget(
          visible: isExpanded,
          portalFollower: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: _toggleAppGridDashboard,
          ),
          child: PortalTarget(
            anchor: Aligned(
              follower: AppUtils.isDirectionRTL(context)
                ? Alignment.topLeft
                : Alignment.topRight,
              target: AppUtils.isDirectionRTL(context)
                ? Alignment.bottomLeft
                : Alignment.bottomRight,
            ),
            portalFollower: AppDashboardOverlay(
              listLinagoraApp: widget.linagoraApps,
              imagePaths: widget.imagePaths,
            ),
            visible: isExpanded,
            child: TMailButtonWidget.fromIcon(
              icon: widget.imagePaths.icAppDashboard,
              backgroundColor: Colors.transparent,
              iconSize: 30,
              padding: const EdgeInsets.all(6),
              onTapActionCallback: _toggleAppGridDashboard,
            ),
          ),
        );
      },
    );
  }

  void _toggleAppGridDashboard() {
    _isExpandedNotifier.value = !_isExpandedNotifier.value;
  }
}
