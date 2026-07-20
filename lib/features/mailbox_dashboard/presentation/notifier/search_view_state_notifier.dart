import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_view_state.dart';

part 'search_view_state_notifier.g.dart';

@Riverpod(keepAlive: true)
class SearchViewStateNotifier extends _$SearchViewStateNotifier {
  @override
  SearchViewState build() => SearchViewState.initial();

  void setSearchInputFocused(bool focused) {
    state = state.copyWith(isSearchInputFocused: focused);
  }

  void openAdvancedSearch() {
    state = state.copyWith(isAdvancedSearchViewOpen: true);
  }

  void closeAdvancedSearch() {
    state = state.copyWith(isAdvancedSearchViewOpen: false);
  }

  void activateSimpleSearch() {
    state = state.copyWith(
      activation: state.activation.copyWith(simpleIsActivated: true),
    );
  }

  void deactivateSimpleSearch() {
    state = state.copyWith(
      activation: state.activation.copyWith(simpleIsActivated: false),
    );
  }

  void activateAdvancedSearch() {
    state = state.copyWith(
      activation: state.activation.copyWith(advancedIsActivated: true),
    );
  }

  void deactivateAdvancedSearch() {
    state = state.copyWith(
      activation: state.activation.copyWith(advancedIsActivated: false),
    );
  }

  void enableSearch() {
    state = state.copyWith(searchState: state.searchState.enableSearchState());
  }

  void disableSearch() {
    state = state.copyWith(searchState: state.searchState.disableSearchState());
  }

  void release() {
    ref.invalidateSelf();
  }
}
