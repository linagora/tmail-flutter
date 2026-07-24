class SearchLayoutTransition {
  const SearchLayoutTransition({
    required this.id,
    required this.isDesktop,
  });

  /// Identifier used to invalidate callbacks from older resize events.
  final int id;

  /// Breakpoint mode that this transition is trying to reconcile.
  final bool isDesktop;
}

class SearchLayoutTransitionState {
  /// Latest responsive mode observed from the browser width.
  bool? _lastObservedDesktop;

  bool? get lastObservedDesktop => _lastObservedDesktop;

  /// Responsive mode for which the latest handoff has been completed.
  bool? _lastReconciledDesktop;

  bool? get lastReconciledDesktop => _lastReconciledDesktop;

  /// Invalidates callbacks queued for older browser width transitions.
  int _transitionId = 0;

  int get transitionId => _transitionId;

  /// Initializes the responsive baseline without triggering a handoff.
  void initialize(bool isDesktop) {
    _lastObservedDesktop = isDesktop;
    _lastReconciledDesktop = isDesktop;
  }

  /// Invalidates callbacks that were scheduled before disposal.
  void invalidateTransitions() {
    _transitionId++;
  }

  /// Records a resize and returns a transition only when reconciliation is
  /// required for the newly observed breakpoint.
  SearchLayoutTransition? observeBreakpoint(bool isDesktop) {
    final wasDesktop = _lastObservedDesktop;
    _lastObservedDesktop = isDesktop;

    // First observation establishes the baseline only.
    if (wasDesktop == null) {
      _lastReconciledDesktop = isDesktop;
      return null;
    }

    // A resize inside an already reconciled breakpoint is a no-op.
    if (wasDesktop == isDesktop && _lastReconciledDesktop == isDesktop) {
      return null;
    }

    // Crossing back to the already reconciled mode cancels the pending
    // transition for the breakpoint we just left.
    if (wasDesktop != isDesktop && _lastReconciledDesktop == isDesktop) {
      invalidateTransitions();
      return null;
    }

    return SearchLayoutTransition(
      id: ++_transitionId,
      isDesktop: isDesktop,
    );
  }

  /// Returns whether a queued transition no longer matches the current state.
  bool shouldSkip(
    SearchLayoutTransition transition, {
    required bool isClosed,
  }) {
    if (isClosed) return true;
    if (transition.id != _transitionId) return true;
    if (_lastObservedDesktop != transition.isDesktop) return true;
    return _lastReconciledDesktop == transition.isDesktop;
  }

  /// Commits the result so failed handoffs can be retried on a later resize.
  void complete(
    SearchLayoutTransition transition, {
    required bool succeeded,
  }) {
    if (transition.id != _transitionId) return;
    _lastReconciledDesktop = succeeded ? transition.isDesktop : null;
  }
}
