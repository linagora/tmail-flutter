import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/state/search_email_presentation_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';

typedef _SearchPresentationMutation = void Function(
  SearchEmailPresentationNotifier notifier,
);

typedef _SearchPresentationExpectation = SearchEmailPresentationState Function(
  SearchEmailPresentationState state,
);

SearchEmailPresentationState _withClearedSuggestions(
  SearchEmailPresentationState state, {
  String? currentSearchText,
}) =>
    state.copyWith(
      currentSearchText: currentSearchText ?? state.currentSearchText,
      listSuggestionSearch: const [],
      listContactSuggestionSearch: const [],
    );

void main() {
  late ProviderContainer container;

  PresentationEmail email(String id) => PresentationEmail(id: EmailId(Id(id)));

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  SearchEmailPresentationNotifier notifierOf() =>
      container.read(searchEmailPresentationProvider.notifier);

  SearchEmailPresentationState stateOf() =>
      container.read(searchEmailPresentationProvider);

  void applyState(SearchEmailPresentationState state) {
    notifierOf()
      ..setCurrentSearchText(state.currentSearchText)
      ..setRecentSearches(state.listRecentSearch)
      ..setSuggestionSearches(state.listSuggestionSearch)
      ..setContactSuggestionSearches(state.listContactSuggestionSearch)
      ..setResultSearches(state.listResultSearch)
      ..setSearchIsRunning(state.searchIsRunning)
      ..setSearchMoreState(state.searchMoreState)
      ..setCanSearchMore(state.canSearchMore)
      ..setSelectionMode(state.selectionMode)
      ..setSuggestionSearchViewState(state.suggestionSearchViewState)
      ..setResultSearchViewState(state.resultSearchViewState);
  }

  SearchEmailPresentationState populatedState({
    bool searchIsRunning = false,
    SearchMoreState searchMoreState = SearchMoreState.idle,
    bool canSearchMore = true,
  }) {
    final state = SearchEmailPresentationState.initial().copyWith(
      currentSearchText: 'report',
      listRecentSearch: [RecentSearch.now('report')],
      listSuggestionSearch: [email('suggestion-1')],
      listContactSuggestionSearch: [
        EmailAddress(null, 'alice@example.com'),
      ],
      listResultSearch: [email('email-1')],
      searchIsRunning: searchIsRunning,
      searchMoreState: searchMoreState,
      canSearchMore: canSearchMore,
    );
    applyState(state);
    return state;
  }

  test('initial state is idle and empty', () {
    expect(stateOf(), SearchEmailPresentationState.initial());
  });

  test('updates mobile search presentation state via notifier', () {
    final resultSearchViewState =
        Left<Failure, Success>(SearchEmailFailure(Exception('boom')));
    final expectedState = SearchEmailPresentationState.initial().copyWith(
      currentSearchText: 'report',
      searchIsRunning: true,
      searchMoreState: SearchMoreState.waiting,
      canSearchMore: false,
      selectionMode: SelectMode.ACTIVE,
      listRecentSearch: [RecentSearch.now('report')],
      listResultSearch: [email('email-1')],
      resultSearchViewState: resultSearchViewState,
    );

    applyState(expectedState);

    expect(stateOf(), expectedState);
  });

  final clearSuggestionStateCases = <({
    String description,
    _SearchPresentationMutation mutation,
    _SearchPresentationExpectation expectedState,
  })>[
    (
      description: 'clearSuggestionState clears email and contact suggestions',
      mutation: (notifier) => notifier.clearSuggestionState(),
      expectedState: _withClearedSuggestions,
    ),
    (
      description: 'clearAllTextInputSearchState clears text and suggestions only',
      mutation: (notifier) => notifier.clearAllTextInputSearchState(),
      expectedState: (state) => _withClearedSuggestions(
        state,
        currentSearchText: '',
      ),
    ),
  ];

  for (final testCase in clearSuggestionStateCases) {
    test(testCase.description, () {
      final stateBeforeClear = populatedState();

      testCase.mutation(notifierOf());

      expect(stateOf(), testCase.expectedState(stateBeforeClear));
    });
  }

  test('updateResultSearches applies the transform to the current results', () {
    final stateBeforeUpdate = populatedState();

    notifierOf().updateResultSearches(
      (current) => [...current, email('email-2')],
    );

    expect(
      stateOf().listResultSearch,
      [...stateBeforeUpdate.listResultSearch, email('email-2')],
    );
  });

  test('resetSearchMore restores the default load-more flags', () {
    final stateBeforeReset = populatedState(
      searchMoreState: SearchMoreState.waiting,
      canSearchMore: false,
    );

    notifierOf().resetSearchMore();

    expect(
      stateOf(),
      stateBeforeReset.copyWith(
        searchMoreState: SearchMoreState.idle,
        canSearchMore: true,
      ),
    );
  });

  test('clearAllResultSearchState clears result-session state', () {
    populatedState(
      searchIsRunning: true,
      searchMoreState: SearchMoreState.waiting,
      canSearchMore: false,
    );

    notifierOf().clearAllResultSearchState();

    expect(stateOf(), SearchEmailPresentationState.initial());
  });

  test('clearAllSearchFilterAppliedState clears filter-related lists', () {
    final stateBeforeClear = populatedState(
      searchIsRunning: true,
      searchMoreState: SearchMoreState.waiting,
      canSearchMore: false,
    );

    notifierOf().clearAllSearchFilterAppliedState();

    expect(
      stateOf(),
      stateBeforeClear.copyWith(
        currentSearchText: '',
        listRecentSearch: const [],
        listSuggestionSearch: const [],
        listContactSuggestionSearch: const [],
        listResultSearch: const [],
        searchMoreState: SearchMoreState.idle,
        canSearchMore: true,
      ),
    );
    // Unlike clearAllResultSearchState, this path keeps the running session flag.
    expect(stateOf().searchIsRunning, isTrue);
  });
}
