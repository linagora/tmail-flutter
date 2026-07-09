import 'dart:async';

import 'package:core/presentation/utils/selection_handles_overlay_guard.dart';
import 'package:flutter/widgets.dart';

/// Suspends Android WebView native selection handles for generic overlay
/// routes, then restores them only for routes it actually suspended.
///
/// Call sites that need owner-specific restore work, such as the composer
/// editor DOM selection, must still use [SelectionHandlesOverlayGuard.protect].
/// Routes opened inside such a manual guard are skipped here so the final
/// restore stays owner-aware.
class SelectionHandlesRouteObserver extends NavigatorObserver {
  final _pendingSuspendedRoutes = <Route<dynamic>>{};
  final _suspendedRoutes = <Route<dynamic>>{};
  final _closedBeforeSuspendRoutes = <Route<dynamic>>{};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (previousRoute == null || !_isOverlayRoute(route)) {
      return;
    }

    _pendingSuspendedRoutes.add(route);
    unawaited(
      SelectionHandlesOverlayGuard.suspend(context: navigator?.context).then((
        suspended,
      ) {
        final closedBeforeSuspend = _closedBeforeSuspendRoutes.remove(route);
        final stillPending = _pendingSuspendedRoutes.remove(route);
        if (!suspended) {
          return;
        }

        if (closedBeforeSuspend || !stillPending) {
          unawaited(SelectionHandlesOverlayGuard.restore());
          return;
        }

        _suspendedRoutes.add(route);
      }),
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _restoreRoute(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _restoreRoute(route);
  }

  void _restoreRoute(Route<dynamic> route) {
    if (_suspendedRoutes.remove(route)) {
      unawaited(SelectionHandlesOverlayGuard.restore());
      return;
    }

    if (_pendingSuspendedRoutes.contains(route)) {
      _closedBeforeSuspendRoutes.add(route);
    }
  }

  bool _isOverlayRoute(Route<dynamic> route) =>
      route is PopupRoute<dynamic> ||
      route is ModalRoute<dynamic> && !route.opaque;
}
