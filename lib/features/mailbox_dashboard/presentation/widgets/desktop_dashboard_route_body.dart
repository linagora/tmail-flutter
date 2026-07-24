import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_view.dart';

typedef DesktopThreadListBuilder = Widget Function(BuildContext context);

/// Maps the current [DashboardRoutes] to the body shown inside the web-desktop
/// content pane. [DashboardRoutes.searchEmail] shares the inline thread list
/// with [DashboardRoutes.thread] so a residual search route left after a
/// responsive handoff renders results instead of a blank pane.
class DesktopDashboardRouteBody extends StatelessWidget {
  const DesktopDashboardRouteBody({
    super.key,
    required this.route,
    required this.threadListBuilder,
  });

  final DashboardRoutes route;
  final DesktopThreadListBuilder threadListBuilder;

  @override
  Widget build(BuildContext context) {
    switch (route) {
      case DashboardRoutes.thread:
      case DashboardRoutes.searchEmail:
        return threadListBuilder(context);
      case DashboardRoutes.threadDetailed:
        return const ThreadDetailView();
      default:
        return const SizedBox.shrink();
    }
  }
}
