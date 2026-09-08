import 'package:core/presentation/utils/web_selection/web_selection_dom_adapter.dart';

/// Non-web build: there is no DOM, so every operation is a no-op.
class PlatformWebSelectionDomAdapter implements WebSelectionDomAdapter {
  PlatformWebSelectionDomAdapter();

  @override
  void clearIframeSelections() {}

  @override
  bool get isIframeFocused => false;

  @override
  void addTopWindowBlurListener(void Function() handler) {}

  @override
  void removeTopWindowBlurListener() {}
}
