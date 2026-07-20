import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/search_filter_notifier_quick_filter_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';

part 'quick_search_filter_action_notifier.g.dart';

typedef SearchFilterMutationAction = void Function(SearchFilterNotifier notifier);

/// Edge-trigger revision for search requests; the value has no domain meaning.
/// Each [next] is distinct so identical searches still notify listeners.
extension type const SearchRequestRevision(int _value) {
  SearchRequestRevision get next => SearchRequestRevision(_value + 1);
}

/// Search trigger for the desktop/web quick-filter bar.
///
/// This notifier does not run the search itself. It commits filter changes to
/// [SearchFilterNotifier], then bumps [SearchRequestRevision] as an edge-trigger
/// signal. `ThreadController` holds a `listen` on this provider and calls
/// `_searchEmail` on every revision change, so mutating this state is what
/// actually executes a search.
@Riverpod(keepAlive: true)
class QuickSearchFilterActionNotifier extends _$QuickSearchFilterActionNotifier {
  @override
  SearchRequestRevision build() => const SearchRequestRevision(0);

  SearchFilterNotifier get _filterNotifier =>
      ref.read(searchFilterProvider.notifier);

  void _requestSearch() {
    // ThreadController listens to this revision and runs `_searchEmail`.
    state = state.next;
  }

  /// Triggers a search when the committed filter is already up to date.
  /// Keeps enter/apply/clear on the same listener path.
  void requestSearch() => _requestSearch();

  /// Applies one committed-filter mutation, then fires one search request.
  /// New filter fields reuse this path instead of wrapper methods.
  void mutateAndSearch(SearchFilterMutationAction mutate) {
    mutate(_filterNotifier);
    _requestSearch();
  }

  bool selectQuickSearchFilter(QuickSearchFilter filter) {
    if (!_filterNotifier.selectQuickSearchFilter(filter)) return false;
    _requestSearch();
    return true;
  }

  bool deleteQuickSearchFilter(QuickSearchFilter filter) {
    if (!_filterNotifier.deleteQuickSearchFilter(filter)) return false;
    _requestSearch();
    return true;
  }
}
