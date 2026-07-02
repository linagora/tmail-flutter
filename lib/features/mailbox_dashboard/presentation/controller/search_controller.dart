import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

class SearchController extends BaseController with DateRangePickerMixin {
  final QuickSearchEmailInteractor quickSearchEmailInteractor;
  final SaveRecentSearchInteractor _saveRecentSearchInteractor;
  final GetAllRecentSearchLatestInteractor _getAllRecentSearchLatestInteractor;

  final searchInputController = TextEditingController();

  /// Read-only mirror of the committed SSOT ([searchFilterProvider]) for existing
  /// `Obx` widgets. Cursors (position/before/after) are still written here locally
  /// by [updateFilterEmail] until the executor owns them (ticket 5).
  final searchEmailFilter = SearchEmailFilter.initial().obs;
  final searchState = SearchState.initial().obs;
  final isAdvancedSearchViewOpen = false.obs;
  final simpleSearchIsActivated = RxBool(false);
  final advancedSearchIsActivated = RxBool(false);
  final isSearchInputFocused = RxBool(false);

  SearchQuery? get searchQuery => searchEmailFilter.value.text;

  FocusNode searchFocus = FocusNode();
  FocusNode? keyboardFocusNode;
  String currentSearchText = '';
  ProviderSubscription<SearchEmailFilter>? _committedFilterSubscription;

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
    // Mirror committed SSOT → obs so existing Obx widgets keep reading it.
    // The SSOT never tracks cursors (before/after/position), so re-layer the
    // obs's local cursors onto every synced value; otherwise an unrelated
    // user-intent update would silently wipe active pagination (until the
    // executor owns cursors — ticket 5).
    _committedFilterSubscription = appProviderContainer.listen<SearchEmailFilter>(
      searchFilterProvider,
      (_, next) => searchEmailFilter.value = next.copyWith(
        beforeOption: optionOf(searchEmailFilter.value.before),
        afterOption: optionOf(searchEmailFilter.value.after),
        positionOption: optionOf(searchEmailFilter.value.position),
      ),
      fireImmediately: true,
    );
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
    appProviderContainer.read(searchFilterProvider.notifier).set(
          SearchEmailFilter.withSortOrder(
            sortOrderType ?? searchEmailFilter.value.sortOrderType,
          ),
        );
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
    // User intent → committed SSOT; the mirror syncs it back into the obs.
    final userIntentOptions = [
      fromOption, toOption, textOption, subjectOption, notKeywordOption,
      hasKeywordOption, mailboxOption, emailReceiveTimeTypeOption,
      hasAttachmentOption, unreadOption, notIncludeEventsOption,
      startDateOption, endDateOption, sortOrderTypeOption, labelOption,
    ];
    if (userIntentOptions.any((option) => option != null)) {
      appProviderContainer.read(searchFilterProvider.notifier).update(
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
            startDateOption: startDateOption,
            endDateOption: endDateOption,
            sortOrderTypeOption: sortOrderTypeOption,
            labelOption: labelOption,
          );
    }
    // Cursors aren't user intent — layered onto the obs only, until the executor
    // owns them (ticket 5).
    if (beforeOption != null || afterOption != null || positionOption != null) {
      searchEmailFilter.value = searchEmailFilter.value.copyWith(
        beforeOption: beforeOption,
        afterOption: afterOption,
        positionOption: positionOption,
      );
      searchEmailFilter.refresh();
    }
  }

  EmailReceiveTimeType get receiveTimeFiltered => searchEmailFilter.value.emailReceiveTimeType;

  void updateSortOrderFilter(EmailSortOrderType sortOrder) {
    updateFilterEmail(
      sortOrderTypeOption: Some(sortOrder),
      beforeOption: const None(),
      afterOption: const None(),
      positionOption: const None(),
    );
  }

  /// Resets load-more cursors before a fresh search so stale pagination state
  /// never leaks into the next query.
  ///
  /// The `before`/`after` time cursors are always cleared (the date-range bounds
  /// in `startDate`/`endDate` are preserved). Position-based pagination
  /// (relevance sort or collapsed threads) restarts from offset 0; otherwise the
  /// position is cleared too.
  void resetCursorsForFreshSearch({required bool isCollapseThreadsEnabled}) {
    final usesPositionPagination =
        searchEmailFilter.value.sortOrderType.isScrollByPosition() ||
            isCollapseThreadsEnabled;
    updateFilterEmail(
      beforeOption: const None(),
      afterOption: const None(),
      positionOption: option(usesPositionPagination, 0),
    );
  }

  /// Toggles a suggestion-bar chip straight on the committed SSOT (no staging), so
  /// the selection takes effect immediately — the fix for #4421.
  void toggleQuickSearchFilter(
    QuickSearchFilter filter, {
    required String currentUserEmail,
  }) {
    final current = searchEmailFilter.value;
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
        final from = Set<String>.of(current.from);
        from.contains(currentUserEmail)
            ? from.remove(currentUserEmail)
            : from.add(currentUserEmail);
        updateFilterEmail(fromOption: Some(from));
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
    _committedFilterSubscription?.close();
    searchInputController.dispose();
    searchFocus.removeListener(_onSearchFocusChanged);
    searchFocus.dispose();
    onKeyboardShortcutDispose();
    super.onClose();
  }
}
