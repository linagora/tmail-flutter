import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/exceptions/local_storage_exception.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_source.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

/// A delegation email link (`/dashboard?account=` or `/settings?type=delegation`) opened while signed out.
/// It is kept in web session storage across the login redirect and opened once after the session loads (ADR-0115).
class SignInEmailLink {
  static const String storageKey = 'delegation.sign_in_email_link';

  final Uri uri;

  const SignInEmailLink._(this.uri);

  /// Only a relative link to one of the two pages is accepted, so a stored value never redirects elsewhere.
  static SignInEmailLink? tryParse(String? link) {
    final uri = Uri.tryParse(link ?? '');
    if (uri == null || _isAbsolute(uri)) return null;
    try {
      return _isEmailLink(uri) ? SignInEmailLink._(uri) : null;
    } on FormatException catch (error) {
      logWarning('SignInEmailLink::tryParse: invalid link: ${error.runtimeType}');
      return null;
    } on ArgumentError catch (error) {
      // An empty id, context or labelId builds an empty Id, which throws.
      logWarning('SignInEmailLink::tryParse: invalid link: ${error.runtimeType}');
      return null;
    }
  }

  static bool _isEmailLink(Uri uri) {
    final router = RouteUtils.parsingRouteParametersToNavigationRouter(uri.queryParameters);
    return switch (uri.path) {
      AppRoutes.dashboard => router.accountId != null,
      AppRoutes.settings => router.accountMenuItem == AccountMenuItem.delegation,
      _ => false,
    };
  }

  static bool _isAbsolute(Uri uri) => uri.hasScheme || uri.hasAuthority;

  bool get opensSettings => uri.path == AppRoutes.settings;

  /// The route parameters the dashboard starts on, or null when the link opens Settings.
  Map<String, String>? get dashboardParameters => opensSettings ? null : uri.queryParameters;
}

/// Called when the app sends the user to the login page without a sign out: keeps the current page when it is an email link.
void keepSignInEmailLinkOfCurrentPage() {
  final route = Uri.parse(Get.currentRoute).path;
  final hasShownAccount = getBinding<ActiveAccountSource>()?.activeAccount != null;
  // An account switch rewrites the location bar with replaceState, so Get.parameters can name a stale account.
  // Before the first session nothing was switched, so the page is still the one opened.
  final parameters = route == AppRoutes.dashboard && hasShownAccount
      ? {RouteUtils.paramAccount: RouteUtils.shownDelegatedAccountId?.id.value}
      : Get.parameters;
  keepSignInEmailLink(route, parameters);
}

/// Keeps [route] when it is an email link, leaves any kept link otherwise.
void keepSignInEmailLink(String route, Map<String, String?> parameters) {
  if (!PlatformInfo.isWeb) return;
  final storage = getBinding<SessionStorageManager>();
  final link = SignInEmailLink.tryParse(
    Uri(
      path: Uri.parse(route).path,
      queryParameters: {
        for (final entry in parameters.entries)
          if (entry.value != null) entry.key: entry.value,
      },
    ).toString(),
  );
  if (storage == null || link == null) return;
  try {
    storage.save(SignInEmailLink.storageKey, link.uri.toString());
  } catch (error, stackTrace) {
    logWarning('keepSignInEmailLink: could not keep the link: $error\n$stackTrace');
  }
}

/// Called on a user sign out or a mailto launch: either ends the intent of a kept link.
void discardSignInEmailLink() => takeSignInEmailLink();

/// Reads the kept link once [accepts] it: an invalid value is removed at once, a valid one only when accepted.
SignInEmailLink? takeSignInEmailLink({SignInEmailLinkFilter? accepts}) {
  final link = _readSignInEmailLink(remove: (link) => link == null || accepts == null || accepts(link));
  return link != null && (accepts == null || accepts(link)) ? link : null;
}

typedef SignInEmailLinkFilter = bool Function(SignInEmailLink link);
typedef _RemovesSignInEmailLink = bool Function(SignInEmailLink? link);

SignInEmailLink? _readSignInEmailLink({required _RemovesSignInEmailLink remove}) {
  if (!PlatformInfo.isWeb) return null;
  final storage = getBinding<SessionStorageManager>();
  if (storage == null) return null;
  try {
    final link = SignInEmailLink.tryParse(storage.get(SignInEmailLink.storageKey));
    if (remove(link)) storage.remove(SignInEmailLink.storageKey);
    return link;
  } on NotFoundDataWithThisKeyException {
    return null;
  }
}
