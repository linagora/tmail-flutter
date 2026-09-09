import 'dart:js_interop';

import 'package:core/presentation/utils/web_selection/web_selection_dom_adapter.dart';
import 'package:core/utils/app_logger.dart';
import 'package:web/web.dart' as web;

/// Web build: touches every `<iframe>` directly (srcdoc iframes are same-origin).
class PlatformWebSelectionDomAdapter implements WebSelectionDomAdapter {
  PlatformWebSelectionDomAdapter();

  static const _flutterViewTag = 'flutter-view';

  JSFunction? _blurListener;

  @override
  void clearIframeSelections() {
    final iframes = web.document.getElementsByTagName('iframe');
    for (var i = 0; i < iframes.length; i++) {
      final element = iframes.item(i);
      if (element == null || !element.isA<web.HTMLIFrameElement>()) continue;
      final iframe = element as web.HTMLIFrameElement;
      _clearSelectionOf(iframe);
      if (web.document.activeElement == iframe) _returnFocusToFlutter(iframe);
    }
  }

  /// Plain `blur()` lands on `<body>` and makes the engine unfocus the region.
  void _returnFocusToFlutter(web.HTMLIFrameElement iframe) {
    final flutterView = iframe.closest(_flutterViewTag);
    if (flutterView != null && flutterView.isA<web.HTMLElement>()) {
      (flutterView as web.HTMLElement).focus();
    } else {
      iframe.blur();
    }
  }

  void _clearSelectionOf(web.HTMLIFrameElement iframe) {
    try {
      iframe.contentWindow?.getSelection()?.removeAllRanges();
    } catch (e) {
      logWarning(
        'PlatformWebSelectionDomAdapter::_clearSelectionOf: Exception = $e',
        webConsoleEnabled: true,
      );
    }
  }

  @override
  bool get isIframeFocused =>
      web.document.activeElement?.isA<web.HTMLIFrameElement>() ?? false;

  @override
  void addTopWindowBlurListener(void Function() handler) {
    removeTopWindowBlurListener();
    _blurListener = ((web.Event _) => handler()).toJS;
    web.window.addEventListener('blur', _blurListener);
  }

  @override
  void removeTopWindowBlurListener() {
    final listener = _blurListener;
    if (listener == null) return;
    web.window.removeEventListener('blur', listener);
    _blurListener = null;
  }
}
