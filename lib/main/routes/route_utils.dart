
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
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
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
  static const String paramTo = 'to';
  static const String paramCc = 'cc';
  static const String paramBcc = 'bcc';

  static const String mailtoPrefix = 'mailto';
  static const String uriPrefix = 'uri';
  static const String ADDRESS_SEPARATOR = ',';
  static const String INVALID_VALUE = 'invalid';

  static String get baseOriginUrl => Uri.base.origin;

  static Uri get baseUri => Uri.base;

  static String generateNavigationRoute(String route, {NavigationRouter? router}) {
    if (PlatformInfo.isWeb) {
      if (route == AppRoutes.dashboard) {
        return _createDashboardServicePath(route, router: router).path;
      } else if (route == AppRoutes.settings) {
        return _createSettingServicePath(route, router: router).path;
      } else {
        return _createServicePath(route).path;
      }
    } else {
      return route;
    }
  }

  static ServicePath _createDashboardServicePath(String route, {NavigationRouter? router}) {
    ServicePath servicePath = ServicePath(route);
    if (router != null) {
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
    } else {
      servicePath = servicePath.withQueryParameters([
        StringQueryParameter(paramType, DashboardType.normal.name)
      ]);
    }
    return servicePath;
  }

  static ServicePath _createSettingServicePath(String route, {NavigationRouter? router}) {
    ServicePath servicePath = ServicePath(route);
    if (router != null && router.accountMenuItem != AccountMenuItem.none) {
      servicePath = servicePath.withQueryParameters([
        StringQueryParameter(paramType, router.accountMenuItem.getAliasBrowser())
      ]);
    }
    return servicePath;
  }

  static ServicePath _createServicePath(String route) {
    ServicePath servicePath = ServicePath(route);
    return servicePath;
  }

  static Uri createUrlWebLocationBar(String route, {NavigationRouter? router}) {
    if (route == AppRoutes.dashboard) {
      final servicePath = _createDashboardServicePath(
        '$baseOriginUrl$route',
        router: router
      );
      return Uri.parse(servicePath.path);
    } else if (route == AppRoutes.settings) {
      final servicePath = _createSettingServicePath('$baseOriginUrl$route', router: router);
      return Uri.parse(servicePath.path);
    } else {
      final servicePath = _createServicePath('$baseOriginUrl$route');
      return Uri.parse(servicePath.path);
    }
  }

  static NavigationRouter parsingRouteParametersToNavigationRouter(Map<String, dynamic> parameters) {
    final idParam = parameters[paramID];
    final typeParam = parameters[paramType];
    final contextPram = parameters[paramContext];
    final queryParam = parameters[paramQuery];
    final routeName = parameters[paramRouteName];
    final mailtoAddress = parameters[paramMailtoAddress];
    final mailtoCc = parameters[paramCc];
    final mailtoBcc = parameters[paramBcc];
    final subject = parameters[paramSubject];
    final body = parameters[paramBody];

    final emailId = idParam != null ? EmailId(Id(idParam)) : null;
    final mailboxId = contextPram != null ? MailboxId(Id(contextPram)) : null;
    final searchQuery = queryParam != null ? SearchQuery(queryParam) : null;
    final dashboardType = DashboardType.values.firstWhereOrNull((type) => type.name == typeParam) ?? DashboardType.normal;
    final settingType = AccountMenuItem.values.firstWhereOrNull((type) => type.getAliasBrowser() == typeParam) ?? AccountMenuItem.none;
    List<EmailAddress>? listEmailAddress;
    List<EmailAddress>? cc;
    List<EmailAddress>? bcc;
    listEmailAddress = _emailAddressesFromMailtoAddress(mailtoAddress);
    cc = _emailAddressesFromMailtoAddress(mailtoCc);
    bcc = _emailAddressesFromMailtoAddress(mailtoBcc);
    log('RouteUtils::parsingRouteParametersToNavigationRouter:listEmailAddress = $listEmailAddress');
    return NavigationRouter(
      emailId: emailId,
      mailboxId: mailboxId,
      searchQuery: searchQuery,
      dashboardType: dashboardType,
      routeName: routeName,
      listEmailAddress: listEmailAddress,
      cc: cc,
      bcc: bcc,
      subject: subject,
      body: body,
      accountMenuItem: settingType,
    );
  }

  static List<EmailAddress>? _emailAddressesFromMailtoAddress(dynamic mailtoAddress) {
    if (mailtoAddress is List<String>) {
      return mailtoAddress
        .map((address) => EmailAddress(null, address))
        .toList();
    } else if (mailtoAddress is String) {
      return [
        EmailAddress(null, mailtoAddress)
      ];
    }
    return null;
  }

  static void replaceBrowserHistory({required String title, required Uri url}) {
    log('RouteUtils::replaceBrowserHistory(): title: $title | url: $url');
    html.window.history.replaceState(null, title, url.toString());
  }

  static Map<String, dynamic> parseMapMailtoFromUri(String? mailtoUri) {
    log('RouteUtils::parseMapMailtoFromUri:mailtoUri: $mailtoUri');
    final mapMailto = <String, dynamic>{
      RouteUtils.paramRouteName: AppRoutes.mailtoURL,
    };
    mailtoUri = mailtoUri == null ? null : Uri.decodeFull(mailtoUri); 
    final parsedMailToUri = Uri.tryParse(mailtoUri ?? '');

    if (parsedMailToUri?.scheme == mailtoPrefix) {
      final to = <String>{
        ...?parsedMailToUri?.path.split(ADDRESS_SEPARATOR),
        ...?parsedMailToUri?.queryParameters[paramTo]?.split(ADDRESS_SEPARATOR)
      }.toList();
      final cc = {
        ...?parsedMailToUri?.queryParameters[paramCc]?.split(ADDRESS_SEPARATOR),
      }.toList();
      final bcc = {
        ...?parsedMailToUri?.queryParameters[paramBcc]?.split(ADDRESS_SEPARATOR),
      }.toList();
      final subject = parsedMailToUri?.queryParameters[paramSubject];
      final body = parsedMailToUri?.queryParameters[paramBody];
      mapMailto[paramMailtoAddress] = to;
      mapMailto[paramCc] = cc;
      mapMailto[paramBcc] = bcc;
      mapMailto[paramSubject] = subject;
      mapMailto[paramBody] = body;
    } else if (parsedMailToUri?.path == "/$mailtoPrefix" || parsedMailToUri?.path == "/$mailtoPrefix/") {
      final to = {
        ...?parsedMailToUri?.queryParameters[uriPrefix]?.split('$mailtoPrefix:').last.split(ADDRESS_SEPARATOR),
        ...?parsedMailToUri?.queryParameters[paramTo]?.split(ADDRESS_SEPARATOR)
      }.toList();
      final cc = {
        ...?parsedMailToUri?.queryParameters[paramCc]?.split(ADDRESS_SEPARATOR),
      }.toList();
      final bcc = {
        ...?parsedMailToUri?.queryParameters[paramBcc]?.split(ADDRESS_SEPARATOR),
      }.toList();
      final subject = parsedMailToUri?.queryParameters[paramSubject];
      final body = parsedMailToUri?.queryParameters[paramBody];
      mapMailto[paramMailtoAddress] = to;
      mapMailto[paramCc] = cc;
      mapMailto[paramBcc] = bcc;
      mapMailto[paramSubject] = subject;
      mapMailto[paramBody] = body;
    } else {
      mapMailto[paramMailtoAddress] = mailtoUri?.split(ADDRESS_SEPARATOR);
    }

    if (mapMailto[paramMailtoAddress]?.length == 1) {
      mapMailto[paramMailtoAddress] = mapMailto[paramMailtoAddress].first;
    }

    log('RouteUtils::parseMapMailtoFromUri:paramMailtoAddress = ${mapMailto[paramMailtoAddress]}');
    log('RouteUtils::parseMapMailtoFromUri:paramCc = ${mapMailto[paramCc]}');
    log('RouteUtils::parseMapMailtoFromUri:paramBcc = ${mapMailto[paramBcc]}');
    log('RouteUtils::parseMapMailtoFromUri:paramSubject = ${mapMailto[paramSubject]}');
    log('RouteUtils::parseMapMailtoFromUri:paramBody = ${mapMailto[paramBody]}');

    return mapMailto;
  }

  static NavigationRouter generateNavigationRouterFromMailtoLink(String mailtoLink) {
    final mailtoMap = parseMapMailtoFromUri(mailtoLink);
    final navigationRouter = parsingRouteParametersToNavigationRouter(mailtoMap);
    log('RouteUtils::generateNavigationRouterFromMailtoLink:navigationRouter: $navigationRouter');
    return navigationRouter;
  }

  static bool canOpenComposerFromNavigationRouter(NavigationRouter navigationRouter) {
    return navigationRouter.listEmailAddress?.isNotEmpty == true
      || navigationRouter.cc?.isNotEmpty == true
      || navigationRouter.bcc?.isNotEmpty == true
      || navigationRouter.subject?.isNotEmpty == true
      || navigationRouter.body?.isNotEmpty == true;
  }
}