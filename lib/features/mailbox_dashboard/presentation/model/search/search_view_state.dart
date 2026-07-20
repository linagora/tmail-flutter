import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_activation_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';

class SearchViewState with EquatableMixin {
  final SearchState searchState;
  final bool isAdvancedSearchViewOpen;
  final SearchActivationState activation;
  final bool isSearchInputFocused;

  const SearchViewState({
    required this.searchState,
    required this.isAdvancedSearchViewOpen,
    required this.activation,
    required this.isSearchInputFocused,
  });

  factory SearchViewState.initial() => SearchViewState(
    searchState: SearchState.initial(),
    isAdvancedSearchViewOpen: false,
    activation: SearchActivationState.initial(),
    isSearchInputFocused: false,
  );

  bool get advancedSearchIsActivated => activation.advancedIsActivated;

  /// True for the whole active search session (search bar open), independent of
  /// whether a query is currently executing.
  bool get isSearchActive => searchState.searchStatus == SearchStatus.ACTIVE;

  bool get isSearchEmailRunning => activation.isRunning;

  /// True while the user is in any search UI — an open session, a running query,
  /// or the advanced-search panel. Both session and running are checked because
  /// [isSearchEmailRunning] drops to false once results load.
  bool get isSearchEngaged =>
      isSearchActive || isSearchEmailRunning || isAdvancedSearchViewOpen;

  SearchViewState copyWith({
    SearchState? searchState,
    bool? isAdvancedSearchViewOpen,
    SearchActivationState? activation,
    bool? isSearchInputFocused,
  }) {
    return SearchViewState(
      searchState: searchState ?? this.searchState,
      isAdvancedSearchViewOpen:
          isAdvancedSearchViewOpen ?? this.isAdvancedSearchViewOpen,
      activation: activation ?? this.activation,
      isSearchInputFocused:
          isSearchInputFocused ?? this.isSearchInputFocused,
    );
  }

  @override
  List<Object?> get props => [
    searchState,
    isAdvancedSearchViewOpen,
    activation,
    isSearchInputFocused,
  ];
}
