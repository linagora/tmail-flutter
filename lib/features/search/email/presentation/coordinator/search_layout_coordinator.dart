import 'dart:async';

import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/search/email/presentation/coordinator/get_search_email_layout_owner_registry.dart';
import 'package:tmail_ui_user/features/search/email/presentation/coordinator/search_email_layout_owner_registry.dart';
import 'package:tmail_ui_user/features/search/email/presentation/coordinator/search_layout_callbacks.dart';
import 'package:tmail_ui_user/features/search/email/presentation/coordinator/search_layout_transition_state.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_executor_service.dart';
import 'package:universal_html/html.dart' as html;

/// Coordinates responsive search ownership without owning mailbox/thread data.
class SearchLayoutCoordinator {
  final ResponsiveUtils _responsiveUtils;
  final SearchExecutorService _searchService;
  final SearchEmailLayoutOwnerRegistry _mobileOwnerRegistry;
  final SearchEngagementResolver _isSearchEngaged;
  final EmailOpenedResolver _isEmailOpened;
  final DesktopSearchHandoffCallback _prepareDesktopSearchHandoff;
  final MobileSearchActivationCallback _activateMobileSearch;
  final SearchRouteDispatcher _dispatchRoute;
  final BrowserResizeCallback? _onBrowserResize;
  final ControllerClosedResolver _isClosed;
  final SearchLayoutTransitionState _transitionState =
      SearchLayoutTransitionState();

  /// Whether the desktop thread list still holds search results and needs a
  /// restore when search closes. Survives a desktop-to-mobile handoff, which
  /// never clears that list.
  bool _desktopSearchPresentationActive = false;

  StreamSubscription<html.Event>? _resizeSubscription;

  SearchLayoutCoordinator({
    required ResponsiveUtils responsiveUtils,
    required SearchExecutorService searchService,
    required SearchEngagementResolver isSearchEngaged,
    required EmailOpenedResolver isEmailOpened,
    required DesktopSearchHandoffCallback prepareDesktopSearchHandoff,
    required MobileSearchActivationCallback activateMobileSearch,
    required SearchRouteDispatcher dispatchRoute,
    required ControllerClosedResolver isClosed,
    SearchEmailLayoutOwnerRegistry mobileOwnerRegistry =
        const GetSearchEmailLayoutOwnerRegistry(),
    BrowserResizeCallback? onBrowserResize,
  })  : _responsiveUtils = responsiveUtils,
        _searchService = searchService,
        _isSearchEngaged = isSearchEngaged,
        _isEmailOpened = isEmailOpened,
        _prepareDesktopSearchHandoff = prepareDesktopSearchHandoff,
        _activateMobileSearch = activateMobileSearch,
        _dispatchRoute = dispatchRoute,
        _isClosed = isClosed,
        _mobileOwnerRegistry = mobileOwnerRegistry,
        _onBrowserResize = onBrowserResize;

  double get _currentBrowserWidth => (html.window.innerWidth ?? 0).toDouble();

  void start() {
    final isDesktop = _responsiveUtils.isMatchedDesktopWidth(
      _currentBrowserWidth,
    );
    _transitionState.initialize(isDesktop);
    _resizeSubscription = html.window.onResize.listen((_) {
      handleBrowserWidthChange(_currentBrowserWidth);
      _onBrowserResize?.call();
    });
  }

  void dispose() {
    _transitionState.invalidateTransitions();
    _resizeSubscription?.cancel();
    _resizeSubscription = null;
  }

  void handleBrowserWidthChange(double width) {
    final isDesktopNow = _responsiveUtils.isMatchedDesktopWidth(width);
    final transition = _transitionState.observeBreakpoint(isDesktopNow);
    if (transition == null) return;

    _scheduleReconciliation(transition);
  }

  /// Waits for the target layout to settle before replaying search results.
  void _scheduleReconciliation(SearchLayoutTransition transition) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_transitionState.shouldSkip(
        transition,
        isClosed: _isClosed(),
      )) {
        return;
      }
      _transitionState.complete(
        transition,
        succeeded: reconcile(transition.isDesktop),
      );
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  /// Replays the active search into the list owner for the current layout.
  /// Returns true when no handoff is needed or the handoff succeeds.
  bool reconcile(bool isDesktop) {
    if (!_isSearchEngaged()) return true;

    if (isDesktop) {
      return _handoffToDesktop();
    } else {
      return _handoffToMobile();
    }
  }

  void markDesktopSearchPresentation() {
    _desktopSearchPresentationActive = true;
  }

  bool takeDesktopSearchPresentation({bool force = false}) {
    if (!force && !_desktopSearchPresentationActive) return false;
    _desktopSearchPresentationActive = false;
    return true;
  }

  /// Makes the desktop thread list the active search presentation owner.
  bool _handoffToDesktop() {
    _dispatchSearchListRouteIfEmailClosed(DashboardRoutes.thread);
    _prepareDesktopSearchHandoff();
    // The desktop thread list now owns the presentation, so mailbox restore can
    // reclaim it via takeDesktopSearchPresentation().
    _desktopSearchPresentationActive = true;
    _searchService.replayCurrentStateToOwners();
    return true;
  }

  /// Prepares the mobile owner before activating it and replaying search data.
  /// A missing owner is a recoverable failure; the next resize can retry.
  bool _handoffToMobile() {
    if (!_mobileOwnerRegistry.tryPrepareForSearchHandoff()) return false;

    // Mobile now shows the results, but the desktop list still holds them
    // behind it. Keep desktop ownership so closing search restores that list.
    _activateMobileSearch();
    _dispatchSearchListRouteIfEmailClosed(DashboardRoutes.searchEmail);
    _searchService.replayCurrentStateToOwners();
    return true;
  }

  /// Keeps the email detail route open while switching only the search list.
  void _dispatchSearchListRouteIfEmailClosed(DashboardRoutes route) {
    if (_isEmailOpened()) return;
    _dispatchRoute(route);
  }
}
