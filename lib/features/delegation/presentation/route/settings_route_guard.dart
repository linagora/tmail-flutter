import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_reader.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

/// Safety net behind the hidden entries: a push of `/settings` while a delegated account is shown
/// builds no Settings and goes back to the dashboard below. See ADR-0114.
class SettingsRouteGuard extends GetMiddleware with ActiveAccountReader {
  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) => _canOpenSettings ? bindings : const [];

  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) =>
      _canOpenSettings ? page : () => const ShownDashboardReturn();

  bool get _canOpenSettings => shownAccountCapabilities.canOpenSettings;
}

class ShownDashboardReturn extends StatefulWidget {
  const ShownDashboardReturn({super.key});

  @override
  State<ShownDashboardReturn> createState() => _ShownDashboardReturnState();
}

class _ShownDashboardReturnState extends State<ShownDashboardReturn> {
  @override
  void initState() {
    super.initState();
    // The navigator is locked while it builds this route.
    WidgetsBinding.instance.addPostFrameCallback((_) => _leave());
  }

  void _leave() {
    if (!mounted) return;
    if (canBack(context)) {
      popBack();
    } else {
      pushAndPopAll(RouteUtils.generateNavigationRoute(AppRoutes.dashboard));
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
