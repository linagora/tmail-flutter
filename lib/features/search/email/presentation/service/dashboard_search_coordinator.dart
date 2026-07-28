import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/providers/search_session_reset.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

/// Reads the dashboard's current filter-message option.
typedef FilterMessageOptionGetter = FilterMessageOption Function();

/// Writes the dashboard's filter-message option.
typedef FilterMessageOptionSetter = void Function(FilterMessageOption option);

/// Keeps the [FilterMessageOption] button and the committed search filter in sync
/// so [MailboxDashBoardController] stays focused. The sync is
/// asymmetric: the button mirrors into search, but search only ever *clears* the
/// button — never sets it — so a criterion enabled directly in search is not
/// mistaken for a button selection. Bridges GetX→Riverpod via injected callbacks.
class DashboardSearchCoordinator {
  DashboardSearchCoordinator({
    required FilterMessageOptionGetter readFilterMessageOption,
    required FilterMessageOptionSetter writeFilterMessageOption,
    ProviderContainer? container,
  })  : _readFilterMessageOption = readFilterMessageOption,
        _writeFilterMessageOption = writeFilterMessageOption,
        _container = container ?? appProviderContainer;

  final FilterMessageOptionGetter _readFilterMessageOption;
  final FilterMessageOptionSetter _writeFilterMessageOption;
  final ProviderContainer _container;

  ProviderSubscription<SearchViewState>? _viewStateSubscription;
  ProviderSubscription<SearchEmailFilter>? _filterSubscription;

  /// The criterion the button currently owns in the committed filter, so a later
  /// option switch knows which one to drop.
  FilterMessageOption _appliedOption = FilterMessageOption.all;

  /// Starts the two-way sync between the button and the committed search filter.
  void start() {
    _viewStateSubscription = _container.listen<SearchViewState>(
      searchViewStateProvider,
      _onSearchViewStateChanged,
    );
    _filterSubscription = _container.listen<SearchEmailFilter>(
      searchFilterProvider,
      _onSearchFilterChanged,
    );
  }

  /// Button → search: re-mirror the button whenever a search surface opens, so a
  /// reopened surface reflects it even after it was toggled off while open.
  void _onSearchViewStateChanged(
    SearchViewState? previous,
    SearchViewState next,
  ) {
    if (_enteredSearchSurface(previous, next)) {
      _applyOptionToSearch(_readFilterMessageOption());
    }
  }

  /// True when [next] opens a search surface that was closed in [previous]: the
  /// active session, the advanced-search panel, or the focused suggestion
  /// dropdown. Each is tracked on its own so reopening one re-seeds even while
  /// another stays open.
  bool _enteredSearchSurface(SearchViewState? previous, SearchViewState next) {
    bool opened(bool Function(SearchViewState) isOpen) =>
        !(previous != null && isOpen(previous)) && isOpen(next);
    return opened((state) => state.isSearchActive) ||
        opened((state) => state.isAdvancedSearchViewOpen) ||
        opened((state) => state.isSearchInputFocused);
  }

  /// Button → search: mirror a live button change into the committed filter.
  void onFilterMessageOptionChanged(FilterMessageOption option) {
    _applyOptionToSearch(option);
  }

  void _applyOptionToSearch(FilterMessageOption option) {
    final current = _container.read(searchFilterProvider);
    var resolved = current;
    if (_appliedOption != option) {
      resolved = _appliedOption.removeFrom(resolved);
    }
    resolved = option.applyTo(resolved);
    _appliedOption = option;
    if (resolved != current) {
      _container.read(searchFilterProvider.notifier).set(resolved);
    }
  }

  /// Search → button (clear only): while search is active, clear the button once
  /// its own criterion is switched off. The active-state guard ignores the
  /// teardown reset, which runs after search is already inactive.
  void _onSearchFilterChanged(
    SearchEmailFilter? previous,
    SearchEmailFilter next,
  ) {
    if (!_container.read(searchViewStateProvider).isSearchActive) return;
    final option = _readFilterMessageOption();
    if (option == FilterMessageOption.all) return;
    if (!option.isActiveIn(next)) {
      _appliedOption = FilterMessageOption.all;
      _writeFilterMessageOption(FilterMessageOption.all);
    }
  }

  /// Stops the sync and resets the search session on dashboard teardown (logout).
  /// [appProviderContainer] is a process-lifetime singleton (ADR-0092), so these
  /// keepAlive providers keep their state across logout; without this reset the
  /// next account's session would inherit the previous filter and cached results
  /// (#4490/#4590). [resetSearchResultSession] clears the results and the
  /// executor's replay marker; the committed filter is reset here.
  void dispose() {
    _viewStateSubscription?.close();
    _viewStateSubscription = null;
    _filterSubscription?.close();
    _filterSubscription = null;
    resetSearchResultSession(_container);
    _container.invalidate(searchFilterProvider);
  }
}
