import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/search_more_state.dart';

class SearchEmailPresentationState with EquatableMixin {
  final String currentSearchText;
  final List<RecentSearch> listRecentSearch;
  final List<PresentationEmail> listSuggestionSearch;
  final List<EmailAddress> listContactSuggestionSearch;
  final List<PresentationEmail> listResultSearch;
  final bool searchIsRunning;
  final SearchMoreState searchMoreState;
  final bool canSearchMore;
  final SelectMode selectionMode;
  final Either<Failure, Success> suggestionSearchViewState;
  final Either<Failure, Success> resultSearchViewState;

  SearchEmailPresentationState({
    required this.currentSearchText,
    required List<RecentSearch> listRecentSearch,
    required List<PresentationEmail> listSuggestionSearch,
    required List<EmailAddress> listContactSuggestionSearch,
    required List<PresentationEmail> listResultSearch,
    required this.searchIsRunning,
    required this.searchMoreState,
    required this.canSearchMore,
    required this.selectionMode,
    required this.suggestionSearchViewState,
    required this.resultSearchViewState,
  })  : listRecentSearch = List.unmodifiable(listRecentSearch),
        listSuggestionSearch = List.unmodifiable(listSuggestionSearch),
        listContactSuggestionSearch =
            List.unmodifiable(listContactSuggestionSearch),
        listResultSearch = List.unmodifiable(listResultSearch);

  factory SearchEmailPresentationState.initial() =>
      SearchEmailPresentationState(
        currentSearchText: '',
        listRecentSearch: const [],
        listSuggestionSearch: const [],
        listContactSuggestionSearch: const [],
        listResultSearch: const [],
        searchIsRunning: false,
        searchMoreState: SearchMoreState.idle,
        canSearchMore: true,
        selectionMode: SelectMode.INACTIVE,
        suggestionSearchViewState: Right(UIState.idle),
        resultSearchViewState: Right(UIState.idle),
      );

  SearchEmailPresentationState copyWith({
    String? currentSearchText,
    List<RecentSearch>? listRecentSearch,
    List<PresentationEmail>? listSuggestionSearch,
    List<EmailAddress>? listContactSuggestionSearch,
    List<PresentationEmail>? listResultSearch,
    bool? searchIsRunning,
    SearchMoreState? searchMoreState,
    bool? canSearchMore,
    SelectMode? selectionMode,
    Either<Failure, Success>? suggestionSearchViewState,
    Either<Failure, Success>? resultSearchViewState,
  }) =>
      SearchEmailPresentationState(
        currentSearchText: currentSearchText ?? this.currentSearchText,
        listRecentSearch: listRecentSearch ?? this.listRecentSearch,
        listSuggestionSearch:
            listSuggestionSearch ?? this.listSuggestionSearch,
        listContactSuggestionSearch:
            listContactSuggestionSearch ?? this.listContactSuggestionSearch,
        listResultSearch: listResultSearch ?? this.listResultSearch,
        searchIsRunning: searchIsRunning ?? this.searchIsRunning,
        searchMoreState: searchMoreState ?? this.searchMoreState,
        canSearchMore: canSearchMore ?? this.canSearchMore,
        selectionMode: selectionMode ?? this.selectionMode,
        suggestionSearchViewState:
            suggestionSearchViewState ?? this.suggestionSearchViewState,
        resultSearchViewState:
            resultSearchViewState ?? this.resultSearchViewState,
      );

  @override
  List<Object?> get props => [
    currentSearchText,
    listRecentSearch,
    listSuggestionSearch,
    listContactSuggestionSearch,
    listResultSearch,
    searchIsRunning,
    searchMoreState,
    canSearchMore,
    selectionMode,
    suggestionSearchViewState,
    resultSearchViewState,
  ];
}
