/// Browser-side operations of the selection coordinator, mockable in tests.
abstract interface class WebSelectionDomAdapter {
  /// Drops every iframe's native selection and returns DOM focus to Flutter.
  void clearIframeSelections();

  /// Whether the top document's active element is an iframe.
  bool get isIframeFocused;

  /// Calls [handler] whenever the top window loses focus.
  void addTopWindowBlurListener(void Function() handler);

  void removeTopWindowBlurListener();
}
