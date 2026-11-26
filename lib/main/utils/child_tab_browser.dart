/// Browser access the cleanup needs, kept apart so it runs without a browser.
abstract class ChildTabBrowser {
  /// May throw when the opener cannot be inspected.
  bool get hasOpener;

  void detachOpener();

  List<String> get sessionStorageKeys;

  void removeSessionStorageKey(String key);
}
