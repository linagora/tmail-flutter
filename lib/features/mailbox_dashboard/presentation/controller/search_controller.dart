import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';

class SearchController extends BaseController with DateRangePickerMixin {
  final QuickSearchEmailInteractor quickSearchEmailInteractor;
  final SaveRecentSearchInteractor _saveRecentSearchInteractor;
  final GetAllRecentSearchLatestInteractor _getAllRecentSearchLatestInteractor;

  final searchInputController = TextEditingController();
  final searchEmailFilter = SearchEmailFilter.initial().obs;
  final searchState = SearchState.initial().obs;
  final isAdvancedSearchViewOpen = false.obs;
  final listFilterOnSuggestionForm = RxList<QuickSearchFilter>();
  final removedSuggestionFilters = RxList<QuickSearchFilter>();
  final simpleSearchIsActivated = RxBool(false);
  final advancedSearchIsActivated = RxBool(false);
  final isSearchInputFocused = RxBool(false);

  SearchQuery? get searchQuery => searchEmailFilter.value.text;

  FocusNode searchFocus = FocusNode();
  FocusNode? keyboardFocusNode;
  String currentSearchText = '';

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
  }

  void _onSearchFocusChanged() {
    log('SearchController::_onSearchFocusChanged: ${searchFocus.hasFocus}');
    isSearchInputFocused.value = searchFocus.hasFocus;
    if (searchFocus.hasFocus) {
      refocusKeyboardShortcutFocus();
    } else {
      clearKeyboardShortcutFocus();
    }
  }

  void openAdvanceSearch() {
    isAdvancedSearchViewOpen.value = true;
  }

  void closeAdvanceSearch() {
    isAdvancedSearchViewOpen.value = false;
  }

  void clearSearchFilter({EmailSortOrderType? sortOrderType}) {
    searchEmailFilter.value = SearchEmailFilter.withSortOrder(
      sortOrderType ?? searchEmailFilter.value.sortOrderType,
    );
  }

  void synchronizeSearchFilter(SearchEmailFilter searchFilter) {
    searchEmailFilter.value = searchFilter;
  }

  void addQuickSearchFilterToSuggestionSearchView(QuickSearchFilter searchFilter) {
    if (!listFilterOnSuggestionForm.contains(searchFilter)) {
      listFilterOnSuggestionForm.add(searchFilter);
    }
    removedSuggestionFilters.remove(searchFilter);
  }

  void deleteQuickSearchFilterFromSuggestionSearchView(QuickSearchFilter searchFilter) {
    listFilterOnSuggestionForm.remove(searchFilter);
  }

  void applyFilterSuggestionToSearchFilter(String currentUserEmail) {
    searchEmailFilter.value = mergeWithSuggestionFilters(currentUserEmail);
    searchEmailFilter.refresh();
  }

  /// Returns a copy of [searchEmailFilter] merged with pending suggestion filters
  /// and with [removedSuggestionFilters] cleared.
  /// Does NOT modify [searchEmailFilter] — dashboard chips unaffected.
  SearchEmailFilter mergeWithSuggestionFilters(String currentUserEmail) {
    final base = searchEmailFilter.value;

    final emailReceiveTimeTypeOption = _mergeReceiveTime();
    final hasAttachmentOption = _mergeHasAttachment();
    final hasKeywordOption = _mergeHasKeyword();
    final fromOption = _mergeFrom(currentUserEmail);

    return base.copyWith(
      emailReceiveTimeTypeOption: emailReceiveTimeTypeOption,
      hasAttachmentOption: hasAttachmentOption,
      hasKeywordOption: hasKeywordOption,
      fromOption: fromOption,
    );
  }

  Option<EmailReceiveTimeType>? _mergeReceiveTime() {
    Option<EmailReceiveTimeType>? emailReceiveTimeTypeOption;
    if (listFilterOnSuggestionForm.contains(QuickSearchFilter.last7Days)) {
      emailReceiveTimeTypeOption = const Some(EmailReceiveTimeType.last7Days);
    } else if (removedSuggestionFilters.contains(QuickSearchFilter.last7Days)) {
      emailReceiveTimeTypeOption = const None();
    }
    return emailReceiveTimeTypeOption;
  }

  Option<bool>? _mergeHasAttachment() {
    Option<bool>? hasAttachmentOption;
    if (listFilterOnSuggestionForm.contains(QuickSearchFilter.hasAttachment)) {
      hasAttachmentOption = const Some(true);
    } else if (removedSuggestionFilters.contains(QuickSearchFilter.hasAttachment)) {
      hasAttachmentOption = const None();
    }
    return hasAttachmentOption;
  }

  Option<Set<String>>? _mergeHasKeyword() {
    Option<Set<String>>? hasKeywordOption;
    if (listFilterOnSuggestionForm.contains(QuickSearchFilter.starred)) {
      hasKeywordOption = Some({KeyWordIdentifier.emailFlagged.value});
    } else if (removedSuggestionFilters.contains(QuickSearchFilter.starred)) {
      hasKeywordOption = const None();
    }
    return hasKeywordOption;
  }

  Option<Set<String>>? _mergeFrom(String currentUserEmail) {
    var listFromAddress = Set<String>.from(searchEmailFilter.value.from);
    Option<Set<String>>? fromOption;
    if (currentUserEmail.isNotEmpty) {
      if (listFilterOnSuggestionForm.contains(QuickSearchFilter.fromMe)) {
        listFromAddress.add(currentUserEmail);
        fromOption = Some(listFromAddress);
      } else if (removedSuggestionFilters.contains(QuickSearchFilter.fromMe)) {
        listFromAddress.remove(currentUserEmail);
        fromOption = Some(listFromAddress);
      }
    }
    return fromOption;
  }

  void clearFilterSuggestion() {
    listFilterOnSuggestionForm.clear();
    removedSuggestionFilters.clear();
  }

  void clearSuggestionFilterState(QuickSearchFilter filter) {
    listFilterOnSuggestionForm.remove(filter);
    removedSuggestionFilters.remove(filter);
  }

  /// Marks [filter] as removed from suggestion view post-search.
  /// Does NOT touch [searchEmailFilter] — dashboard chips unaffected.
  void syncFromSuggestionPostSearch(QuickSearchFilter filter) {
    if (!removedSuggestionFilters.contains(filter)) {
      removedSuggestionFilters.add(filter);
    }
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
    Option<UTCDate>? startDateOption,
    Option<UTCDate>? endDateOption,
    Option<int>? positionOption,
    Option<EmailSortOrderType>? sortOrderTypeOption,
    Option<Label>? labelOption,
  }) {
    if (fromOption != null) clearSuggestionFilterState(QuickSearchFilter.fromMe);
    if (hasAttachmentOption != null) clearSuggestionFilterState(QuickSearchFilter.hasAttachment);
    if (emailReceiveTimeTypeOption != null) clearSuggestionFilterState(QuickSearchFilter.last7Days);
    if (hasKeywordOption != null) clearSuggestionFilterState(QuickSearchFilter.starred);

    searchEmailFilter.value = searchEmailFilter.value.copyWith(
      fromOption: fromOption,
      toOption: toOption,
      textOption: textOption,
      subjectOption: subjectOption,
      notKeywordOption: notKeywordOption,
      hasKeywordOption: hasKeywordOption,
      mailboxOption: mailboxOption,
      emailReceiveTimeTypeOption: emailReceiveTimeTypeOption,
      hasAttachmentOption: hasAttachmentOption,
      unreadOption: unreadOption,
      notIncludeEventsOption: notIncludeEventsOption,
      beforeOption: beforeOption,
      startDateOption: startDateOption,
      endDateOption: endDateOption,
      positionOption: positionOption,
      sortOrderTypeOption: sortOrderTypeOption,
      labelOption: labelOption,
    );
    searchEmailFilter.refresh();
  }

  EmailReceiveTimeType get receiveTimeFiltered => searchEmailFilter.value.emailReceiveTimeType;

  DateTime? get startDateFiltered => searchEmailFilter.value.startDate?.value.toLocal();

  DateTime? get endDateFiltered => searchEmailFilter.value.endDate?.value.toLocal();

  PresentationMailbox? get mailboxFiltered => searchEmailFilter.value.mailbox;

  Label? get labelFiltered => searchEmailFilter.value.label;

  Set<String> get listAddressOfToFiltered => searchEmailFilter.value.to;

  Set<String> get listAddressOfFromFiltered => searchEmailFilter.value.from;

  Set<String> get listHasKeywordFiltered => searchEmailFilter.value.hasKeyword;

  bool get unreadFiltered => searchEmailFilter.value.unread;

  bool get notIncludeEventsFiltered => searchEmailFilter.value.notIncludeEvents;

  EmailSortOrderType get sortOrderFiltered => searchEmailFilter.value.sortOrderType;

  bool isSearchActive() =>
      searchState.value.searchStatus == SearchStatus.ACTIVE;

  bool get isSearchEmailRunning => simpleSearchIsActivated.isTrue || advancedSearchIsActivated.isTrue;

  void enableSearch() {
    searchState.value = searchState.value.enableSearchState();
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
    simpleSearchIsActivated.value = true;
  }

  void deactivateSimpleSearch() {
    simpleSearchIsActivated.value = false;
  }

  void activateAdvancedSearch() {
    advancedSearchIsActivated.value = true;
  }

  void deactivateAdvancedSearch() {
    advancedSearchIsActivated.value = false;
  }

  void hideAdvancedSearchFormView() {
    isAdvancedSearchViewOpen.value = false;
  }

  void hideSimpleSearchFormView() {
    searchState.value = searchState.value.disableSearchState();
  }

  void _clearAllTextInputSimpleSearch() {
    searchInputController.clear();
    searchFocus.unfocus();
  }

  void clearAllFilterSearch() {
    _clearAllTextInputSimpleSearch();
    clearFilterSuggestion();
    clearSearchFilter();
    deactivateAdvancedSearch();
    hideAdvancedSearchFormView();
  }

  void disableAllSearchEmail() {
    _clearAllTextInputSimpleSearch();
    deactivateSimpleSearch();
    hideSimpleSearchFormView();

    clearSearchFilter();
    clearFilterSuggestion();
    deactivateAdvancedSearch();
    hideAdvancedSearchFormView();
  }

  @override
  void onClose() {
    searchInputController.dispose();
    searchFocus.removeListener(_onSearchFocusChanged);
    searchFocus.dispose();
    onKeyboardShortcutDispose();
    super.onClose();
  }
}
