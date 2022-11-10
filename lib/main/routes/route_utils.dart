
import 'package:core/core.dart';
import 'package:core/data/model/query/query_parameter.dart';
import 'package:core/data/network/config/service_path.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:universal_html/html.dart' as html;

abstract class RouteUtils {

  static String get baseOriginUrl => Uri.base.origin;

  static String get baseUrl => Uri.base.path;

  static String generateNavigationRoute(String route, NavigationRouter router) {
    ServicePath servicePath = ServicePath(route);
    if (BuildUtils.isWeb) {
      if (router.emailId != null) {
        servicePath = servicePath.withPathParameter(router.emailId!.id.value);
      }
      servicePath = servicePath.withQueryParameters([
        StringQueryParameter('type', router.dashboardType.name),
        if (router.mailboxId != null)
          StringQueryParameter('context', router.mailboxId!.id.value),
        if (router.searchQuery != null)
          StringQueryParameter('q', router.searchQuery!.value),
      ]);
      return servicePath.path;
    } else {
      return servicePath.path;
    }
  }

  static Uri generateRouteBrowser(String route, NavigationRouter router) {
    final baseRoutePath = '$baseOriginUrl/#$route';
    ServicePath servicePath = ServicePath(baseRoutePath);
    if (router.emailId != null) {
      servicePath = servicePath.withPathParameter(router.emailId!.id.value);
    }
    servicePath = servicePath.withQueryParameters([
      StringQueryParameter('type', router.dashboardType.name),
      if (router.mailboxId != null)
        StringQueryParameter('context', router.mailboxId!.id.value),
      if (router.searchQuery != null)
        StringQueryParameter('q', router.searchQuery!.value),
    ]);

    return Uri.parse(servicePath.path);
  }

  static NavigationRouter parsingRouteParametersToNavigationRouter(Map<String, String?> parameters) {
    final idParam = parameters['id'];
    final typeParam = parameters['type'];
    final contextPram = parameters['context'];
    final queryParam = parameters['q'];

    final emailId = idParam != null ? EmailId(Id(idParam)) : null;
    final mailboxId = contextPram != null ? MailboxId(Id(contextPram)) : null;
    final searchQuery = queryParam != null ? SearchQuery(queryParam) : null;
    final dashboardType = typeParam == DashboardType.search.name
      ? DashboardType.search
      : DashboardType.normal;

    return NavigationRouter(
      emailId: emailId,
      mailboxId: mailboxId,
      searchQuery: searchQuery,
      dashboardType: dashboardType,
    );
  }

  static void updateRouteOnBrowser(String title, Uri newRoute) {
    log('RouteUtils::updateRouteOnBrowser(): title: $title');
    log('RouteUtils::updateRouteOnBrowser(): newRoute: $newRoute');
    html.window.history.replaceState(null, title, newRoute.toString());
  }
}