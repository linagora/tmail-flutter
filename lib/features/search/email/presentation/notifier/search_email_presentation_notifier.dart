import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/email/presentation/state/search_email_presentation_state.dart';

part 'search_email_presentation_notifier.g.dart';

typedef ResultSearchesTransform = List<PresentationEmail> Function(
  List<PresentationEmail> current,
);

@Riverpod(keepAlive: true)
class SearchEmailPresentationNotifier
    extends _$SearchEmailPresentationNotifier {
  @override
  SearchEmailPresentationState build() =>
      SearchEmailPresentationState.initial();

  void setCurrentSearchText(String text) {
    state = state.copyWith(currentSearchText: text);
  }

  void setRecentSearches(List<RecentSearch> recentSearches) {
    state = state.copyWith(listRecentSearch: recentSearches);
  }

  void clearRecentSearches() {
    state = state.copyWith(listRecentSearch: const []);
  }

  void setSuggestionSearches(List<PresentationEmail> suggestionSearches) {
    state = state.copyWith(listSuggestionSearch: suggestionSearches);
  }

  void clearSuggestionSearches() {
    state = state.copyWith(listSuggestionSearch: const []);
  }

  void setContactSuggestionSearches(
    List<EmailAddress> contactSuggestionSearches,
  ) {
    state = state.copyWith(
      listContactSuggestionSearch: contactSuggestionSearches,
    );
  }

  void clearContactSuggestionSearches() {
    state = state.copyWith(listContactSuggestionSearch: const []);
  }

  void setResultSearches(List<PresentationEmail> resultSearches) {
    state = state.copyWith(listResultSearch: resultSearches);
  }

  void clearResultSearches() {
    state = state.copyWith(listResultSearch: const []);
  }

  void updateResultSearches(ResultSearchesTransform transform) {
    state = state.copyWith(
      listResultSearch: transform(state.listResultSearch),
    );
  }

  void clearSuggestionState() {
    state = state.copyWith(
      listSuggestionSearch: const [],
      listContactSuggestionSearch: const [],
    );
  }

  void setSearchIsRunning(bool isRunning) {
    state = state.copyWith(searchIsRunning: isRunning);
  }

  void setSearchMoreState(SearchMoreState searchMoreState) {
    state = state.copyWith(searchMoreState: searchMoreState);
  }

  void setCanSearchMore(bool canSearchMore) {
    state = state.copyWith(canSearchMore: canSearchMore);
  }

  void resetSearchMore() {
    state = state.copyWith(
      searchMoreState: SearchMoreState.idle,
      canSearchMore: true,
    );
  }

  void setSelectionMode(SelectMode selectionMode) {
    state = state.copyWith(selectionMode: selectionMode);
  }

  void setSuggestionSearchViewState(Either<Failure, Success> viewState) {
    state = state.copyWith(suggestionSearchViewState: viewState);
  }

  void setResultSearchViewState(Either<Failure, Success> viewState) {
    state = state.copyWith(resultSearchViewState: viewState);
  }

  void clearAllTextInputSearchState() {
    state = state.copyWith(
      currentSearchText: '',
      listSuggestionSearch: const [],
      listContactSuggestionSearch: const [],
    );
  }

  void clearAllResultSearchState() {
    state = _resetCommonSearchState(searchIsRunning: false);
  }

  void clearAllSearchFilterAppliedState() {
    state = _resetCommonSearchState();
  }

  /// Shared reset for clear-all paths.
  SearchEmailPresentationState _resetCommonSearchState({bool? searchIsRunning}) {
    return state.copyWith(
      searchIsRunning: searchIsRunning ?? state.searchIsRunning,
      searchMoreState: SearchMoreState.idle,
      canSearchMore: true,
      currentSearchText: '',
      listRecentSearch: const [],
      listSuggestionSearch: const [],
      listContactSuggestionSearch: const [],
      listResultSearch: const [],
      selectionMode: SelectMode.INACTIVE,
      suggestionSearchViewState: Right(UIState.idle),
      resultSearchViewState: Right(UIState.idle),
    );
  }
}
