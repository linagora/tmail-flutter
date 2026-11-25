import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

/// Platform access of [openInNewTab], replaceable in tests.
class AppRouteTabEnvironment {
  const AppRouteTabEnvironment();

  bool get isWeb => PlatformInfo.isWeb;

  String currentOrigin() => Uri.base.origin;

  /// Opens an app route in a new tab. On web basic auth, same-origin routes are
  /// opened without noopener so the tab inherits this tab's login; every other
  /// case goes through [launch] and keeps noopener.
  void openInNewTab(String url, {required bool isBasicAuth}) {
    if (isBasicAuth && canShareSession(url)) {
      if (openTabKeepingSession(url)) return;
    }
    launch(url);
  }

  /// True when [url] is an absolute http(s) url on this app's origin, on web.
  bool canShareSession(String url) {
    if (!isWeb) return false;
    try {
      // Uri.origin throws for relative and non-http(s) urls.
      return Uri.parse(url).origin == currentOrigin();
    } catch (_) {
      return false;
    }
  }

  /// Returns false when the browser refused to open the tab.
  bool openTabKeepingSession(String url) =>
      HtmlUtils.openNewWindowByUrl(url, isFullScreen: true);

  void launch(String url) => AppUtils.launchLink(url);
}
