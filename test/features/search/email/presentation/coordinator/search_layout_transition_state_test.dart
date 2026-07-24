import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/search/email/presentation/coordinator/search_layout_transition_state.dart';

void main() {
  group('SearchLayoutTransitionState', () {
    late SearchLayoutTransitionState state;

    setUp(() {
      state = SearchLayoutTransitionState();
    });

    // Starts on desktop and crosses to mobile, returning the pending transition.
    SearchLayoutTransition arrangePendingMobileTransition() {
      state.initialize(true);
      return state.observeBreakpoint(false)!;
    }

    void expectSkipped(SearchLayoutTransition transition) {
      expect(state.shouldSkip(transition, isClosed: false), isTrue);
    }

    test('first observation establishes the responsive baseline', () {
      expect(state.observeBreakpoint(true), isNull);
      expect(state.lastObservedDesktop, isTrue);
      expect(state.lastReconciledDesktop, isTrue);
      expect(state.transitionId, 0);
    });

    test('same breakpoint after a successful handoff is ignored', () {
      state.initialize(true);

      expect(state.observeBreakpoint(true), isNull);
      expect(state.transitionId, 0);
    });

    test('breakpoint crossing creates a transition', () {
      state.initialize(true);

      final transition = state.observeBreakpoint(false);

      expect(transition?.id, 1);
      expect(transition?.isDesktop, isFalse);
    });

    test('successful transition marks the target breakpoint as reconciled', () {
      final transition = arrangePendingMobileTransition();

      state.complete(transition, succeeded: true);

      expect(state.observeBreakpoint(false), isNull);
      expect(state.lastReconciledDesktop, isFalse);
    });

    test('crossing back invalidates the pending transition', () {
      final pendingTransition = arrangePendingMobileTransition();

      expect(state.observeBreakpoint(true), isNull);
      expectSkipped(pendingTransition);
    });

    test('failed transition remains retryable in the same breakpoint', () {
      final transition = arrangePendingMobileTransition();
      state.complete(transition, succeeded: false);

      final retry = state.observeBreakpoint(false);

      expect(retry?.id, 2);
      expect(retry?.isDesktop, isFalse);
    });

    test('disposed state skips its pending transition', () {
      final transition = arrangePendingMobileTransition();

      state.invalidateTransitions();

      expectSkipped(transition);
    });
  });
}
