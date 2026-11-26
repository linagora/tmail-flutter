import 'package:tmail_ui_user/main/utils/child_tab_browser.dart';

/// Only the web build has tabs and a tab opener.
class PlatformChildTabBrowser implements ChildTabBrowser {
  @override
  bool get hasOpener => false;

  @override
  void detachOpener() {}

  @override
  List<String> get sessionStorageKeys => const [];

  @override
  void removeSessionStorageKey(String key) {}
}
