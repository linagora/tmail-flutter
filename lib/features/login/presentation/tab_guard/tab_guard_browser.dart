import 'dart:async';

import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:universal_html/html.dart' as html;

/// Browser access the tab guard needs, kept apart so its decisions run without a browser.
abstract class TabGuardBrowser {
  /// Key of every `storage` event; null when the whole storage was cleared.
  Stream<String?> get storageEventKeys;

  /// Fires when the page becomes visible or is restored from the back/forward cache.
  Stream<void> get pageActivations;

  bool get isEmlPreviewRoute;

  /// Returns whether the tab is gone afterwards.
  bool tryCloseTab();

  void replaceWithLoginPage();
}

class WebTabGuardBrowser implements TabGuardBrowser {
  @override
  Stream<String?> get storageEventKeys =>
      html.window.onStorage.map((event) => event.key);

  @override
  Stream<void> get pageActivations => Stream.multi((controller) {
        final subscriptions = [
          html.document.onVisibilityChange
              .where((_) => html.document.visibilityState == 'visible')
              .listen((_) => controller.add(null)),
          html.window.onPageShow.listen((_) => controller.add(null)),
        ];
        controller.onCancel = () {
          for (final subscription in subscriptions) {
            subscription.cancel();
          }
        };
      });

  @override
  bool get isEmlPreviewRoute =>
      Uri.base.path.endsWith(AppRoutes.emailEMLPreviewer);

  @override
  bool tryCloseTab() {
    html.window.close();
    return html.window.closed ?? false;
  }

  // Relative to <base href>, like every other web route URL, so sub-path deployments stay inside the app.
  @override
  void replaceWithLoginPage() {
    final base = Uri.parse(html.document.baseUri ?? Uri.base.origin);
    final login = base.resolve(AppRoutes.login.substring(1));
    html.window.location.replace(login.toString());
  }
}
