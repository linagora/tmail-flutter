import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';

typedef _SearchViewMutation = void Function();
typedef _SearchActivationFlag = bool Function();

void main() {
  late ProviderContainer container;
  late _DisposeObserver disposeObserver;

  setUp(() {
    disposeObserver = _DisposeObserver();
    container = ProviderContainer(observers: [disposeObserver]);
  });
  tearDown(() => container.dispose());

  SearchViewStateNotifier notifier() =>
      container.read(searchViewStateProvider.notifier);
  SearchViewState state() => container.read(searchViewStateProvider);

  test('starts from an inactive, closed, unfocused state', () {
    expect(state().isAdvancedSearchViewOpen, isFalse);
    expect(state().isSearchInputFocused, isFalse);
    expect(state().isSearchActive, isFalse);
    expect(state().isSearchEmailRunning, isFalse);
  });

  test('openAdvancedSearch then closeAdvancedSearch toggles the advanced view', () {
    notifier().openAdvancedSearch();
    expect(state().isAdvancedSearchViewOpen, isTrue);

    notifier().closeAdvancedSearch();
    expect(state().isAdvancedSearchViewOpen, isFalse);
  });

  test('setSearchInputFocused reflects focus both ways', () {
    notifier().setSearchInputFocused(true);
    expect(state().isSearchInputFocused, isTrue);

    notifier().setSearchInputFocused(false);
    expect(state().isSearchInputFocused, isFalse);
  });

  test('enableSearch then disableSearch flips the search status', () {
    notifier().enableSearch();
    expect(state().isSearchActive, isTrue);
    expect(state().searchState.searchStatus, SearchStatus.ACTIVE);

    notifier().disableSearch();
    expect(state().isSearchActive, isFalse);
    expect(state().searchState.searchStatus, SearchStatus.INACTIVE);
  });

  void testIndependentActivation({
    required String description,
    required _SearchViewMutation activatePreserved,
    required _SearchViewMutation activateTarget,
    required _SearchViewMutation deactivateTarget,
    required _SearchActivationFlag targetIsActivated,
    required _SearchActivationFlag preservedIsActivated,
    required String preservedReason,
  }) {
    test(description, () {
      activatePreserved();

      activateTarget();
      expect(targetIsActivated(), isTrue);
      expect(preservedIsActivated(), isTrue);

      deactivateTarget();
      expect(targetIsActivated(), isFalse);
      expect(preservedIsActivated(), isTrue, reason: preservedReason);
    });
  }

  testIndependentActivation(
    description: 'simple activation toggles on and off without touching advanced',
    activatePreserved: () => notifier().activateAdvancedSearch(),
    activateTarget: () => notifier().activateSimpleSearch(),
    deactivateTarget: () => notifier().deactivateSimpleSearch(),
    targetIsActivated: () => state().activation.simpleIsActivated,
    preservedIsActivated: () => state().activation.advancedIsActivated,
    preservedReason: 'advanced activation must be independent of simple',
  );

  testIndependentActivation(
    description: 'advanced activation toggles on and off without touching simple',
    activatePreserved: () => notifier().activateSimpleSearch(),
    activateTarget: () => notifier().activateAdvancedSearch(),
    deactivateTarget: () => notifier().deactivateAdvancedSearch(),
    targetIsActivated: () => state().activation.advancedIsActivated,
    preservedIsActivated: () => state().activation.simpleIsActivated,
    preservedReason: 'simple activation must be independent of advanced',
  );

  test('isSearchEmailRunning is true while either simple or advanced is active', () {
    expect(state().isSearchEmailRunning, isFalse);

    notifier().activateSimpleSearch();
    expect(state().isSearchEmailRunning, isTrue);

    notifier().deactivateSimpleSearch();
    notifier().activateAdvancedSearch();
    expect(state().isSearchEmailRunning, isTrue);

    notifier().deactivateAdvancedSearch();
    expect(state().isSearchEmailRunning, isFalse);
  });

  test('isSearchEngaged is true for a session, a running query, or advanced open', () {
    expect(state().isSearchEngaged, isFalse);

    notifier().enableSearch();
    expect(state().isSearchEngaged, isTrue, reason: 'active session');

    notifier().disableSearch();
    notifier().activateSimpleSearch();
    expect(state().isSearchEngaged, isTrue, reason: 'query running');

    notifier().deactivateSimpleSearch();
    notifier().openAdvancedSearch();
    expect(state().isSearchEngaged, isTrue, reason: 'advanced panel open');

    notifier().closeAdvancedSearch();
    expect(state().isSearchEngaged, isFalse);
  });

  test('release disposes the keepAlive provider back to initial', () async {
    notifier().openAdvancedSearch();
    notifier().enableSearch();

    notifier().release();
    await container.pump();

    expect(disposeObserver.searchViewStateDisposeCount, greaterThan(0));
    expect(state().isAdvancedSearchViewOpen, isFalse);
    expect(state().isSearchActive, isFalse);
  });
}

final class _DisposeObserver extends ProviderObserver {
  int searchViewStateDisposeCount = 0;

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    if (context.provider == searchViewStateProvider) {
      searchViewStateDisposeCount++;
    }
  }
}
