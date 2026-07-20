import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/date_range_picker_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_recent_search_latest_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_keyboard_shortcut_actions_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_constants.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

class SearchController extends BaseController with DateRangePickerMixin {
  final QuickSearchEmailInteractor quickSearchEmailInteractor;
  final SaveRecentSearchInteractor _saveRecentSearchInteractor;
  final GetAllRecentSearchLatestInteractor _getAllRecentSearchLatestInteractor;

  final searchInputController = TextEditingController();

  SearchEmailFilter get _committedFilter =>
      appProviderContainer.read(searchFilterProvider);

  SearchFilterNotifier get _searchFilterNotifier =>
      appProviderContainer.read(searchFilterProvider.notifier);

  SearchViewState get _searchViewState =>
      appProviderContainer.read(searchViewStateProvider);

  SearchViewStateNotifier get _searchViewStateNotifier =>
      appProviderContainer.read(searchViewStateProvider.notifier);

  SearchQuery? get searchQuery => _committedFilter.text;

  FocusNode searchFocus = FocusNode();
  FocusNode? keyboardFocusNode;
  ProviderSubscription<SearchEmailFilter>? _committedFilterSubscription;

  /// Debounces committing the search-bar text into the committed SSOT on the
  /// shared [SearchConstants.inputDebounceDuration] (same cadence as suggestions).
  /// Flushed synchronously by [commitSearchTextNow].
  Timer? _commitSearchTextDebounce;

  /// Local re-entrancy guard for the search-bar ↔ SSOT.text round-trip. Kept as a
  /// plain field (not shared state) since no widget observes it — only
  /// [_syncSearchInputFromFilter] reads/writes it, synchronously.
  bool _isSyncingSearchInputFromFilter = false;

  SearchController(
    this.quickSearchEmailInteractor,
    this._saveRecentSearchInteractor,
    this._getAllRecentSearchLatestInteractor,
  );

  @override
  void onInit() {
    super.onInit();
    searchFocus.addListener(_onSearchFocusChanged);
    onKeyboardShortcutInit();
    _committedFilterSubscription = appProviderContainer.listen<SearchEmailFilter>(
      searchFilterProvider,
      (_, next) => _syncSearchInputFromFilter(next.text),
      fireImmediately: true,
    );
    searchInputController.addListener(_onSearchInputChanged);
  }

  /// Debounces search-bar edits into the committed filter text (SSOT), so the
  /// input feeds the SSOT on the same cadence as the suggestion search.
  void _onSearchInputChanged() {
    if (_isSyncingSearchInputFromFilter) return;
    _commitSearchTextDebounce?.cancel();
    _commitSearchTextDebounce =
        Timer(SearchConstants.inputDebounceDuration, _commitSearchText);
  }

  void _commitSearchText() {
    _searchFilterNotifier.setText(
      searchInputController.text.asSearchFilterTextInput(),
    );
  }

  /// Flushes the pending debounced search-bar text into the SSOT immediately, so
  /// the suggestion fetch and submit query read an up-to-date SSOT instead of
  /// waiting out the debounce.
  void commitSearchTextNow() {
    _commitSearchTextDebounce?.cancel();
    _commitSearchText();
  }

  /// Mirrors committed filter text back onto the search bar.
  void _syncSearchInputFromFilter(SearchQuery? text) {
    final nextText = text?.value ?? '';
    if (searchInputController.text.trim() == nextText.trim()) return;
    _isSyncingSearchInputFromFilter = true;
    searchInputController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
    _isSyncingSearchInputFromFilter = false;
  }

  void _onSearchFocusChanged() {
    log('SearchController::_onSearchFocusChanged: ${searchFocus.hasFocus}');
    _searchViewStateNotifier.setSearchInputFocused(searchFocus.hasFocus);
    if (searchFocus.hasFocus) {
      refocusKeyboardShortcutFocus();
    } else {
      clearKeyboardShortcutFocus();
    }
  }

  void openAdvanceSearch() {
    _searchViewStateNotifier.openAdvancedSearch();
  }

  void closeAdvanceSearch() {
    _searchViewStateNotifier.closeAdvancedSearch();
  }

  void clearSearchFilter({EmailSortOrderType? sortOrderType}) {
    final restoredSortOrder =
        sortOrderType ?? _committedFilter.sortOrderType;
    final clearedFilter = SearchEmailFilter.withSortOrder(restoredSortOrder);

    _searchFilterNotifier.set(clearedFilter);
  }

  EmailReceiveTimeType get receiveTimeFiltered => _committedFilter.emailReceiveTimeType;

  void updateSortOrderFilter(EmailSortOrderType sortOrder) {
    _searchFilterNotifier.setSortOrder(sortOrder);
  }

  /// Toggles a suggestion chip directly on the committed filter. Each branch
  /// self-toggles from the notifier's own state, so callers only pass the
  /// [searchFilterNotifier] (from `ref`) — no filter snapshot needed.
  void toggleQuickSearchFilter(
    QuickSearchFilter filter, {
    required String currentUserEmail,
    required SearchFilterNotifier searchFilterNotifier,
  }) {
    switch (filter) {
      case QuickSearchFilter.hasAttachment:
        searchFilterNotifier.toggleHasAttachment();
        break;
      case QuickSearchFilter.last7Days:
        searchFilterNotifier.toggleLast7Days();
        break;
      case QuickSearchFilter.fromMe:
        searchFilterNotifier.toggleOnlySender(currentUserEmail);
        break;
      case QuickSearchFilter.starred:
        searchFilterNotifier.toggleStarred();
        break;
      default:
        break;
    }
  }

  DateTime? get startDateFiltered => _committedFilter.startDate?.value.toLocal();

  DateTime? get endDateFiltered => _committedFilter.endDate?.value.toLocal();

  PresentationMailbox? get mailboxFiltered => _committedFilter.mailbox;

  Label? get labelFiltered => _committedFilter.label;

  Set<String> get listAddressOfToFiltered => _committedFilter.to;

  Set<String> get listAddressOfFromFiltered => _committedFilter.from;

  Set<String> get listHasKeywordFiltered => _committedFilter.hasKeyword;

  EmailSortOrderType get sortOrderFiltered => _committedFilter.sortOrderType;

  bool get isOnlyStarredApplied => _committedFilter.isOnlyStarredApplied;

  // NOTE: `unread`/`notIncludeEvents` are read straight from `searchFilterProvider`
  // by their widgets, so no pass-through getters are exposed here.

  bool isSearchActive() =>
      _searchViewState.searchState.searchStatus == SearchStatus.ACTIVE;

  bool get isSearchEmailRunning => _searchViewState.isSearchEmailRunning;

  void enableSearch() {
    _searchViewStateNotifier.enableSearch();
  }

  void clearTextSearch() {
    searchInputController.clear();
    commitSearchTextNow();
    searchFocus.requestFocus();
  }

  void updateTextSearch(String value) {
    searchInputController.text = value;
  }

  void saveRecentSearch(
    AccountId accountId,
    UserName userName,
    RecentSearch recentSearch,
  ) {
    consumeState(_saveRecentSearchInteractor.execute(
      accountId,
      userName,
      recentSearch,
    ));
  }

  Future<List<RecentSearch>> getAllRecentSearchAction(
    AccountId accountId,
    UserName userName,
    String pattern,
  ) async {
    return await _getAllRecentSearchLatestInteractor
        .execute(accountId, userName, pattern: pattern)
        .then((result) => result.fold(
            (failure) => <RecentSearch>[],
            (success) => success is GetAllRecentSearchLatestSuccess
                ? success.listRecentSearch
                : <RecentSearch>[]));
  }

  void activateSimpleSearch() {
    _searchViewStateNotifier.activateSimpleSearch();
  }

  void deactivateSimpleSearch() {
    _searchViewStateNotifier.deactivateSimpleSearch();
  }

  void activateAdvancedSearch() {
    _searchViewStateNotifier.activateAdvancedSearch();
  }

  void deactivateAdvancedSearch() {
    _searchViewStateNotifier.deactivateAdvancedSearch();
  }

  void hideAdvancedSearchFormView() {
    _searchViewStateNotifier.closeAdvancedSearch();
  }

  void hideSimpleSearchFormView() {
    _searchViewStateNotifier.disableSearch();
  }

  void _clearAllTextInputSimpleSearch() {
    searchInputController.clear();
    searchFocus.unfocus();
  }

  void clearAllFilterSearch() {
    _clearAllTextInputSimpleSearch();
    clearSearchFilter();
    deactivateAdvancedSearch();
    hideAdvancedSearchFormView();
  }

  void disableAllSearchEmail() {
    _clearAllTextInputSimpleSearch();
    deactivateSimpleSearch();
    hideSimpleSearchFormView();

    clearSearchFilter();
    deactivateAdvancedSearch();
    hideAdvancedSearchFormView();
  }

  @override
  void onClose() {
    _searchViewStateNotifier.release();
    _commitSearchTextDebounce?.cancel();
    _committedFilterSubscription?.close();
    searchInputController.removeListener(_onSearchInputChanged);
    searchInputController.dispose();
    searchFocus.removeListener(_onSearchFocusChanged);
    searchFocus.dispose();
    onKeyboardShortcutDispose();
    super.onClose();
  }
}
