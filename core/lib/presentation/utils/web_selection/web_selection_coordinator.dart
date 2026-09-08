import 'dart:async';

import 'package:core/presentation/utils/flutter_selection_clearer.dart';
import 'package:core/presentation/utils/web_selection/platform_web_selection_dom_adapter.dart';
import 'package:core/presentation/utils/web_selection/web_selection_dom_adapter.dart';
import 'package:flutter/widgets.dart';

/// Keeps Flutter's selection and every iframe's native selection mutually exclusive.
class WebSelectionCoordinator {
  WebSelectionCoordinator({WebSelectionDomAdapter? dom})
      : _dom = dom ?? PlatformWebSelectionDomAdapter();

  static final WebSelectionCoordinator instance = WebSelectionCoordinator();

  final WebSelectionDomAdapter _dom;
  FocusManager get _focusManager => FocusManager.instance;
  bool _started = false;

  bool get isStarted => _started;

  void start() {
    if (_started) return;
    _started = true;
    _focusManager.addListener(_handleFlutterFocusChanged);
    _dom.addTopWindowBlurListener(_handleTopWindowBlur);
  }

  void stop() {
    if (!_started) return;
    _started = false;
    _focusManager.removeListener(_handleFlutterFocusChanged);
    _dom.removeTopWindowBlurListener();
  }

  /// A Flutter selection surface took focus: drop every iframe selection.
  void _handleFlutterFocusChanged() {
    final context = _focusManager.primaryFocus?.context;
    if (context == null || !_isFlutterSelectionSurface(context)) return;
    _dom.clearIframeSelections();
  }

  /// The single place to extend if more Flutter surfaces must take part.
  static bool _isFlutterSelectionSurface(BuildContext context) =>
      context.findAncestorStateOfType<SelectableRegionState>() != null;

  /// Deferred one tick so `activeElement` already points at the iframe.
  void _handleTopWindowBlur() {
    Timer.run(() {
      if (!_started || !_dom.isIframeFocused) return;
      final context = _focusManager.primaryFocus?.context;
      if (context == null) return;
      FlutterSelectionClearer.clearSelectableRegionOf(context);
    });
  }
}
