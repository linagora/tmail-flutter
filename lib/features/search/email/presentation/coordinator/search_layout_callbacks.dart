import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';

typedef SearchEngagementResolver = bool Function();

typedef EmailOpenedResolver = bool Function();

typedef DesktopSearchHandoffCallback = void Function();

typedef MobileSearchActivationCallback = void Function();

typedef SearchRouteDispatcher = void Function(DashboardRoutes route);

typedef BrowserResizeCallback = void Function();

typedef ControllerClosedResolver = bool Function();
