import 'package:tmail_ui_user/main/utils/child_tab_browser.dart';
import 'package:web/web.dart' as web;

/// Reads the raw JS values: `dart:html` wraps a JS `null` opener into a
/// non-null object, so `window.opener != null` there is always true.
class PlatformChildTabBrowser implements ChildTabBrowser {
  @override
  bool get hasOpener => web.window.opener != null;

  @override
  void detachOpener() => web.window.opener = null;

  @override
  List<String> get sessionStorageKeys {
    final storage = web.window.sessionStorage;
    return [
      for (var i = 0; i < storage.length; i++)
        if (storage.key(i) case final key?) key,
    ];
  }

  @override
  void removeSessionStorageKey(String key) =>
      web.window.sessionStorage.removeItem(key);
}
