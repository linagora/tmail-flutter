
import 'package:core/data/model/query/query_parameter.dart';
import 'package:core/data/network/config/service_path.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:universal_html/html.dart' as html;

abstract class RouteUtils {

  static const String paramID = 'id';
  static const String paramType = 'type';
  static const String paramContext = 'context';
  static const String paramQuery = 'q';
  static const String paramRouteName = 'routeName';
  static const String paramMailtoAddress = 'mailtoAddress';
  static const String paramSubject = 'subject';
  static const String paramBody = 'body';

  static const String mailtoPrefix = 'mailto:';

  static const String INVALID_VALUE = 'invalid';

  static String get baseOriginUrl => Uri.base.origin;

  static String get baseUrl => Uri.base.path;

  static String generateNavigationRoute(String route, NavigationRouter router) {
    ServicePath servicePath = ServicePath(route);
    if (PlatformInfo.isWeb) {
      if (router.emailId != null) {
        servicePath = servicePath.withPathParameter(router.emailId!.id.value);
      }
      servicePath = servicePath.withQueryParameters([
        StringQueryParameter(paramType, router.dashboardType.name),
        if (router.mailboxId != null)
          StringQueryParameter(paramContext, router.mailboxId!.id.value),
        if (router.searchQuery != null)
          StringQueryParameter(paramQuery, router.searchQuery!.value),
      ]);
      return servicePath.path;
    } else {
      return servicePath.path;
    }
  }

  static Uri generateRouteBrowser(String route, NavigationRouter router) {
    final baseRoutePath = '$baseOriginUrl$route';
    ServicePath servicePath = ServicePath(baseRoutePath);
    if (router.emailId != null) {
      servicePath = servicePath.withPathParameter(router.emailId!.id.value);
    }
    servicePath = servicePath.withQueryParameters([
      StringQueryParameter(paramType, router.dashboardType.name),
      if (router.mailboxId != null)
        StringQueryParameter(paramContext, router.mailboxId!.id.value),
      if (router.searchQuery != null)
        StringQueryParameter(paramQuery, router.searchQuery!.value),
    ]);

    return Uri.parse(servicePath.path);
  }

  static NavigationRouter parsingRouteParametersToNavigationRouter(Map<String, String?> parameters) {
    final idParam = parameters[paramID];
    final typeParam = parameters[paramType];
    final contextPram = parameters[paramContext];
    final queryParam = parameters[paramQuery];
    final routeName = parameters[paramRouteName];
    final mailtoAddress = parameters[paramMailtoAddress];
    final subject = parameters[paramSubject];
    final body = parameters[paramBody];

    final emailId = idParam != null ? EmailId(Id(idParam)) : null;
    final mailboxId = contextPram != null ? MailboxId(Id(contextPram)) : null;
    final searchQuery = queryParam != null ? SearchQuery(queryParam) : null;
    final dashboardType = typeParam == DashboardType.search.name
      ? DashboardType.search
      : DashboardType.normal;
    final emailAddress = mailtoAddress != null && GetUtils.isEmail(mailtoAddress)
      ? EmailAddress(null, mailtoAddress)
      : EmailAddress(null, INVALID_VALUE);

    return NavigationRouter(
      emailId: emailId,
      mailboxId: mailboxId,
      searchQuery: searchQuery,
      dashboardType: dashboardType,
      routeName: routeName,
      emailAddress: emailAddress,
      subject: subject,
      body: body,
    );
  }

  static void updateRouteOnBrowser(String title, Uri newRoute) {
    log('RouteUtils::updateRouteOnBrowser(): title: $title');
    log('RouteUtils::updateRouteOnBrowser(): newRoute: $newRoute');
    html.window.history.replaceState(null, title, newRoute.toString());
  }

  static Map<String, String?> parseMapMailtoFromUri(String? mailtoUri) {
    log('RouteUtils::parseMapMailtoFromUri:mailtoUri: $mailtoUri');
    final mapMailto = <String, String?>{
      RouteUtils.paramRouteName: AppRoutes.mailtoURL,
    };
    if (mailtoUri?.startsWith(mailtoPrefix) == true) {
      final mailtoUrlDecoded = Uri.decodeFull(mailtoUri!);
      final uri = Uri.tryParse(mailtoUrlDecoded);
      if (uri == null) return mapMailto;

      final mailtoAddress = uri.path;
      final mapQueryParam = uri.queryParameters;

      mapMailto[paramMailtoAddress] = mailtoAddress;
      if (mapQueryParam.containsKey(paramSubject)) {
        mapMailto[paramSubject] = mapQueryParam[paramSubject];
      }
      if (mapQueryParam.containsKey(paramBody)) {
        mapMailto[paramBody] = mapQueryParam[paramBody];
      }
    } else if (mailtoUri != null) {
      final mailtoUrlDecoded = Uri.decodeFull(mailtoUri);
      mapMailto[paramMailtoAddress] = mailtoUrlDecoded;
    } else {
      mapMailto[paramMailtoAddress] = mailtoUri;
    }
    log('RouteUtils::parseMapMailtoFromUri:mapMailto: $mapMailto');
    return mapMailto;
  }

  static NavigationRouter generateNavigationRouterFromMailtoLink(String mailtoLink) {
    final mailtoMap = parseMapMailtoFromUri(mailtoLink);
    final navigationRouter = parsingRouteParametersToNavigationRouter(mailtoMap);
    log('RouteUtils::generateNavigationRouterFromMailtoLink:navigationRouter: $navigationRouter');
    return navigationRouter;
  }
}