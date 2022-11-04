
import 'package:core/data/model/query/query_parameter.dart';
import 'package:core/data/network/config/service_path.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';

class BrowserRouteUtils {

  static String get baseOriginUrl => Uri.base.origin;

  static Uri generateRoutePathBrowser(String route, NavigationRouter router) {
    final baseRoutePath = '$baseOriginUrl/#$route';
    ServicePath servicePath = ServicePath(baseRoutePath);
    if (router.emailId != null) {
      servicePath = servicePath.withPathParameter(router.emailId!.id.value);
    }
    servicePath = servicePath.withQueryParameters([
      StringQueryParameter('type', router.dashboardType.name),
      if (router.mailboxId != null)
        StringQueryParameter('context', router.mailboxId!.id.value),
    ]);

    log('BrowserRouteUtils::generateRoutePathForBrowser(): routePath: ${servicePath.path}');
    return Uri.parse(servicePath.path);
  }

  static NavigationRouter parsingRouteParametersToNavigationRouter(Map<String, String?> parameters) {
    final idParam = parameters['id'];
    final typeParam = parameters['type'];
    final contextPram = parameters['context'];

    log('BrowserRouteUtils::parsingRouteParametersToNavigationRouter(): idParam: $idParam');
    log('BrowserRouteUtils::parsingRouteParametersToNavigationRouter(): typeParam: $typeParam');
    log('BrowserRouteUtils::parsingRouteParametersToNavigationRouter(): contextPram: $contextPram');

    final emailId = idParam != null ? EmailId(Id(idParam)) : null;
    final mailboxId = contextPram != null ? MailboxId(Id(contextPram)) : null;
    final dashboardType = typeParam == DashboardType.search.name
      ? DashboardType.search
      : DashboardType.normal;

    return NavigationRouter(
      emailId: emailId,
      mailboxId: mailboxId,
      dashboardType: dashboardType,
    );
  }
}