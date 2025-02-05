import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_filter_condition_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/date_range_picker_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_recent_search_latest_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';

class SearchController extends BaseController with DateRangePickerMixin {
  final QuickSearchEmailInteractor _quickSearchEmailInteractor;
  final SaveRecentSearchInteractor _saveRecentSearchInteractor;
  final GetAllRecentSearchLatestInteractor _getAllRecentSearchLatestInteractor;

  final searchInputController = TextEditingController();
  final searchEmailFilter = SearchEmailFilter.initial().obs;
  final searchState = SearchState.initial().obs;
  final isAdvancedSearchViewOpen = false.obs;
  final listFilterOnSuggestionForm = RxList<QuickSearchFilter>();
  final simpleSearchIsActivated = RxBool(false);
  final advancedSearchIsActivated = RxBool(false);

  SearchQuery? get searchQuery => searchEmailFilter.value.text;

  FocusNode searchFocus = FocusNode();
  String currentSearchText = '';

  SearchController(
    this._quickSearchEmailInteractor,
    this._saveRecentSearchInteractor,
    this._getAllRecentSearchLatestInteractor,
  );

  void openAdvanceSearch() {
    isAdvancedSearchViewOpen.value = true;
  }

  void closeAdvanceSearch() {
    isAdvancedSearchViewOpen.value = false;
  }

  void clearSearchFilter() {
    searchEmailFilter.value = SearchEmailFilter.initial();
  }

  void synchronizeSearchFilter(SearchEmailFilter searchFilter) {
    searchEmailFilter.value = searchFilter;
  }

  void addQuickSearchFilterToSuggestionSearchView(QuickSearchFilter searchFilter) {
    if (!listFilterOnSuggestionForm.contains(searchFilter)) {
      listFilterOnSuggestionForm.add(searchFilter);
    }
  }

  void deleteQuickSearchFilterFromSuggestionSearchView(QuickSearchFilter searchFilter) {
    listFilterOnSuggestionForm.remove(searchFilter);
  }

  Future<List<PresentationEmail>> quickSearchEmails({
    required Session session,
    required AccountId accountId,
    required String query,
  }) async {
    currentSearchText = query;
    return await _quickSearchEmailInteractor.execute(
      session,
      accountId,
      limit: UnsignedInt(5),
      sort: <Comparator>{}..add(
        EmailComparator(EmailComparatorProperty.receivedAt)
          ..setIsAscending(false)),
      filter: _mappingToFilterOnSuggestionForm(userName: session.username, query: query),
      properties: EmailUtils.getPropertiesForEmailGetMethod(session, accountId),
    ).then((result) => result.fold(
      (failure) => <PresentationEmail>[],
      (success) => success is QuickSearchEmailSuccess
        ? success.emailList
        : <PresentationEmail>[]
    ));
  }

  Filter? _mappingToFilterOnSuggestionForm({required String query, required UserName userName}) {
    log('SearchController::_mappingToFilterOnSuggestionForm():query: $query');
    final filterCondition = EmailFilterCondition(
      text: query.isNotEmpty == true ? query : null,
      after: listFilterOnSuggestionForm.contains(QuickSearchFilter.last7Days)
        ? EmailReceiveTimeType.last7Days.toOldestUTCDate()
        : null,
      before: listFilterOnSuggestionForm.contains(QuickSearchFilter.last7Days)
        ? EmailReceiveTimeType.last7Days.toLatestUTCDate()
        : null,
      hasAttachment: listFilterOnSuggestionForm.contains(QuickSearchFilter.hasAttachment)
        ? true
        : null,
      from: listFilterOnSuggestionForm.contains(QuickSearchFilter.fromMe)
        ? userName.value
        : null,
      hasKeyword: listFilterOnSuggestionForm.contains(QuickSearchFilter.starred)
        ? KeyWordIdentifier.emailFlagged.value
        : null
    );

    return filterCondition.hasCondition
      ? filterCondition
      : null;
  }

  void applyFilterSuggestionToSearchFilter(UserName? userName) {
    final receiveTime = listFilterOnSuggestionForm.contains(QuickSearchFilter.last7Days)
      ? EmailReceiveTimeType.last7Days
      : EmailReceiveTimeType.allTime;

    final hasAttachment = listFilterOnSuggestionForm.contains(QuickSearchFilter.hasAttachment) ? true : false;

    var listFromAddress = searchEmailFilter.value.from;
    if (userName != null) {
      if (listFilterOnSuggestionForm.contains(QuickSearchFilter.fromMe)) {
        listFromAddress.add(userName.value);
      } else {
        listFromAddress.remove(userName.value);
      }
    }

    final listHasKeyword = listFilterOnSuggestionForm.contains(QuickSearchFilter.starred)
      ? {KeyWordIdentifier.emailFlagged.value}
      : null;

    updateFilterEmail(
      emailReceiveTimeTypeOption: Some(receiveTime),
      hasAttachmentOption: Some(hasAttachment),
      fromOption: Some(listFromAddress),
      hasKeywordOption: optionOf(listHasKeyword),
    );

    clearFilterSuggestion();
  }

  void clearFilterSuggestion() {
    listFilterOnSuggestionForm.clear();
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
    Option<UTCDate>? beforeOption,
    Option<UTCDate>? startDateOption,
    Option<UTCDate>? endDateOption,
    Option<int>? positionOption,
    Option<EmailSortOrderType>? sortOrderTypeOption,
  }) {
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
      beforeOption: beforeOption,
      startDateOption: startDateOption,
      endDateOption: endDateOption,
      positionOption: positionOption,
      sortOrderTypeOption: sortOrderTypeOption,
    );
    searchEmailFilter.refresh();
  }

  EmailReceiveTimeType get receiveTimeFiltered => searchEmailFilter.value.emailReceiveTimeType;

  DateTime? get startDateFiltered => searchEmailFilter.value.startDate?.value.toLocal();

  DateTime? get endDateFiltered => searchEmailFilter.value.endDate?.value.toLocal();

  PresentationMailbox? get mailboxFiltered => searchEmailFilter.value.mailbox;

  Set<String> get listAddressOfToFiltered => searchEmailFilter.value.to;

  Set<String> get listAddressOfFromFiltered => searchEmailFilter.value.from;

  EmailSortOrderType get sortOrderFiltered => searchEmailFilter.value.sortOrderType;

  bool isSearchActive() =>
      searchState.value.searchStatus == SearchStatus.ACTIVE;

  bool get isSearchEmailRunning => simpleSearchIsActivated.isTrue || advancedSearchIsActivated.isTrue;

  void enableSearch() {
    searchState.value = searchState.value.enableSearchState();
  }

  void disableSimpleSearch() {
    updateFilterEmail(textOption: Some(SearchQuery.initial()));
    _clearAllTextInputSimpleSearch();
    deactivateSimpleSearch();
    hideSimpleSearchFormView();
  }

  void clearTextSearch() {
    searchInputController.clear();
    searchFocus.requestFocus();
  }

  void updateTextSearch(String value) {
    searchInputController.text = value;
  }

  void saveRecentSearch(RecentSearch recentSearch) {
    consumeState(_saveRecentSearchInteractor.execute(recentSearch));
  }

  Future<List<RecentSearch>> getAllRecentSearchAction(String pattern) async {
    return await _getAllRecentSearchLatestInteractor
        .execute(pattern: pattern)
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
    deactivateAdvancedSearch();
    hideAdvancedSearchFormView();
  }

  @override
  void onClose() {
    searchInputController.dispose();
    searchFocus.dispose();
    super.onClose();
  }
}
