import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/providers/search_session_reset.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

class SearchController extends BaseController with DateRangePickerMixin {
  final QuickSearchEmailInteractor quickSearchEmailInteractor;
  final SaveRecentSearchInteractor _saveRecentSearchInteractor;
  final GetAllRecentSearchLatestInteractor _getAllRecentSearchLatestInteractor;

  final searchInputController = TextEditingController();

  SearchEmailFilter get committedSearchFilter =>
      appProviderContainer.read(searchFilterProvider);

  SearchQuery? get searchQuery => committedSearchFilter.text;

  FocusNode searchFocus = FocusNode();
  FocusNode? keyboardFocusNode;
  ProviderSubscription<SearchEmailFilter>? _committedFilterSubscription;

  SearchViewStateNotifier get _searchViewStateNotifier =>
      appProviderContainer.read(searchViewStateProvider.notifier);

  /// Guards the search-bar ↔ SSOT.text round-trip so mirroring the committed
  /// term back into [searchInputController] never re-enters as a fresh edit.
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
      (_, next) {
        _syncSearchInputFromFilter(next.text);
      },
      fireImmediately: true,
    );
    searchInputController.addListener(_onSearchInputChanged);
  }

  /// Push search-bar edits into the committed SSOT so the advanced "has the
  /// words" field (and result chips) always reflect the same full-text term.
  void _onSearchInputChanged() {
    if (_isSyncingSearchInputFromFilter) return;
    final value = searchInputController.text.trim();
    updateFilterEmail(
      textOption: option(value.isNotEmpty, SearchQuery(value)),
    );
  }

  /// Mirror the committed full-text term back onto the search bar. Compares on
  /// trimmed text so a trailing space being typed is not wiped mid-edit.
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
        sortOrderType ?? committedSearchFilter.sortOrderType;
    final clearedFilter = SearchEmailFilter.withSortOrder(restoredSortOrder);
    appProviderContainer
        .read(searchFilterProvider.notifier)
        .set(clearedFilter);
  }

  void updateFilterEmail({
    Option<Set<String>>? fromOption,
    Option<Set<String>>? toOption,
    Option<SearchQuery>? textOption,
    Option<String>? subjectOption,
    Option<Set<String>>? notKeywordOption,
    Option<Set<String>>? hasKeywordOption,
    Option<PresentationMailbox>? mailboxOption,
    Option<EmailReceiveTimeType>? emailReceiveTimeTypeOption,
    Option<bool>? hasAttachmentOption,
    Option<bool>? unreadOption,
    Option<bool>? notIncludeEventsOption,
    Option<UTCDate>? beforeOption,
    Option<UTCDate>? afterOption,
    Option<UTCDate>? startDateOption,
    Option<UTCDate>? endDateOption,
    Option<int>? positionOption,
    Option<EmailSortOrderType>? sortOrderTypeOption,
    Option<Label>? labelOption,
  }) {
    final userIntentOptions = [
      fromOption, toOption, textOption, subjectOption, notKeywordOption,
      hasKeywordOption, mailboxOption, emailReceiveTimeTypeOption,
      hasAttachmentOption, unreadOption, notIncludeEventsOption,
      startDateOption, endDateOption, sortOrderTypeOption, labelOption,
    ];
    if (userIntentOptions.any((option) => option != null)) {
      appProviderContainer.read(searchFilterProvider.notifier).update(
            SearchFilterPatch()
              ..fromOption = fromOption
              ..toOption = toOption
              ..textOption = textOption
              ..subjectOption = subjectOption
              ..notKeywordOption = notKeywordOption
              ..hasKeywordOption = hasKeywordOption
              ..mailboxOption = mailboxOption
              ..emailReceiveTimeTypeOption = emailReceiveTimeTypeOption
              ..hasAttachmentOption = hasAttachmentOption
              ..unreadOption = unreadOption
              ..notIncludeEventsOption = notIncludeEventsOption
              ..startDateOption = startDateOption
              ..endDateOption = endDateOption
              ..sortOrderTypeOption = sortOrderTypeOption
              ..labelOption = labelOption);
    }
  }

  EmailReceiveTimeType get receiveTimeFiltered =>
      committedSearchFilter.emailReceiveTimeType;

  void updateSortOrderFilter(EmailSortOrderType sortOrder) {
    updateFilterEmail(
      sortOrderTypeOption: Some(sortOrder),
      beforeOption: const None(),
      afterOption: const None(),
      positionOption: const None(),
    );
  }

  /// Toggles a suggestion-bar chip straight on the committed SSOT (no staging), so
  /// the selection takes effect immediately — the fix for #4421.
  void toggleQuickSearchFilter(
    QuickSearchFilter filter, {
    required String currentUserEmail,
  }) {
    final current = committedSearchFilter;
    switch (filter) {
      case QuickSearchFilter.hasAttachment:
        updateFilterEmail(
          hasAttachmentOption:
              current.hasAttachment ? const None() : const Some(true),
        );
        break;
      case QuickSearchFilter.last7Days:
        if (current.emailReceiveTimeType == EmailReceiveTimeType.last7Days) {
          updateFilterEmail(
            emailReceiveTimeTypeOption: const Some(EmailReceiveTimeType.allTime),
            startDateOption: const None(),
            endDateOption: const None(),
          );
        } else {
          final range = EmailReceiveTimeType.last7Days.toDateRange();
          updateFilterEmail(
            emailReceiveTimeTypeOption: const Some(EmailReceiveTimeType.last7Days),
            startDateOption: optionOf(range.start),
            endDateOption: optionOf(range.end),
          );
        }
        break;
      case QuickSearchFilter.fromMe:
        if (currentUserEmail.isEmpty) return;
        // Selecting collapses `from` to just the current user; deselecting clears
        // it. Any other sender means it isn't selected, so a tap selects it.
        updateFilterEmail(
          fromOption: Some(
            current.isOnlySender(currentUserEmail)
                ? const <String>{}
                : {currentUserEmail},
          ),
        );
        break;
      case QuickSearchFilter.starred:
        final keywords = Set<String>.of(current.hasKeyword);
        final flagged = KeyWordIdentifier.emailFlagged.value;
        keywords.contains(flagged)
            ? keywords.remove(flagged)
            : keywords.add(flagged);
        updateFilterEmail(hasKeywordOption: Some(keywords));
        break;
      default:
        break;
    }
  }

  DateTime? get startDateFiltered =>
      committedSearchFilter.startDate?.value.toLocal();

  DateTime? get endDateFiltered => committedSearchFilter.endDate?.value.toLocal();

  PresentationMailbox? get mailboxFiltered => committedSearchFilter.mailbox;

  Label? get labelFiltered => committedSearchFilter.label;

  Set<String> get listAddressOfToFiltered => committedSearchFilter.to;

  Set<String> get listAddressOfFromFiltered => committedSearchFilter.from;

  Set<String> get listHasKeywordFiltered =>
      Set<String>.unmodifiable(committedSearchFilter.hasKeyword);

  bool get unreadFiltered => committedSearchFilter.unread;

  bool get notIncludeEventsFiltered => committedSearchFilter.notIncludeEvents;

  EmailSortOrderType get sortOrderFiltered => committedSearchFilter.sortOrderType;

  bool isSearchActive() =>
      appProviderContainer.read(searchViewStateProvider).isSearchActive;

  bool get isSearchEmailRunning =>
      appProviderContainer.read(searchViewStateProvider).isSearchEmailRunning;

  void enableSearch() {
    _searchViewStateNotifier.enableSearch();
  }

  void clearTextSearch() {
    searchInputController.clear();
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
    closeAdvanceSearch();
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

    resetSearchResultSession(appProviderContainer);
  }

  @override
  void onClose() {
    _committedFilterSubscription?.close();
    searchInputController.removeListener(_onSearchInputChanged);
    searchInputController.dispose();
    searchFocus.removeListener(_onSearchFocusChanged);
    searchFocus.dispose();
    onKeyboardShortcutDispose();
    appProviderContainer.invalidate(searchViewStateProvider);
    super.onClose();
  }
}
