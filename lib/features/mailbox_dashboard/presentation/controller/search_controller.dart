import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/quick_search_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';

class SearchController extends BaseController {
  final QuickSearchEmailInteractor _quickSearchEmailInteractor;

  final searchEmailFilter = SearchEmailFilter().obs;

  TextEditingController searchInputController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  final searchState = SearchState.initial().obs;

  SearchController(
    this._quickSearchEmailInteractor,
  );

  cleanSearchFilter() {
    searchEmailFilter.value = SearchEmailFilter();
  }

  void selectQuickSearchFilter({
    required QuickSearchFilter quickSearchFilter,
    required UserProfile userProfile,
    bool fromSuggestionBox = false,
  }) {
    final isSelected = checkQuickSearchFilterSelected(
      quickSearchFilter,
      userProfile,
      fromSuggestionBox,
    );

    switch (quickSearchFilter) {
      case QuickSearchFilter.hasAttachment:
        final HasAttachment? hasAttachment =
            isSelected ? HasAttachment.all : HasAttachment.yes;
        updateFilterEmail(hasAttachment: hasAttachment);
        return;
      case QuickSearchFilter.last7Days:
        final EmailReceiveTimeType? emailReceiveTimeType = isSelected
            ? EmailReceiveTimeType.anyTime
            : EmailReceiveTimeType.last7Days;
        updateFilterEmail(emailReceiveTimeType: emailReceiveTimeType);
        return;
      case QuickSearchFilter.fromMe:
        isSelected
            ? searchEmailFilter.value.from.remove(userProfile.email)
            : searchEmailFilter.value.from.add(userProfile.email);
        updateFilterEmail(from: searchEmailFilter.value.from);
        return;
    }
  }

  Future<List<PresentationEmail>> quickSearchEmails(AccountId? accountId) async {
    if (accountId != null) {
      return await _quickSearchEmailInteractor.execute(
          accountId,
          limit: UnsignedInt(5),
          sort: <Comparator>{}
            ..add(EmailComparator(EmailComparatorProperty.receivedAt)
              ..setIsAscending(false)),
          filter: searchEmailFilter.value.mappingToListEmailFilterCondition(),
          properties: ThreadConstants.propertiesQuickSearch
      ).then((result) => result.fold(
              (failure) => <PresentationEmail>[],
              (success) => success is QuickSearchEmailSuccess ? success.emailList : <PresentationEmail>[]));
    }
    return <PresentationEmail>[];
  }

  void updateFilterEmail({
    Set<String>? from,
    Set<String>? to,
    SearchQuery? text,
    String? subject,
    String? hasKeyword,
    String? notKeyword,
    MailboxId? mailBoxId,
    EmailReceiveTimeType? emailReceiveTimeType,
    HasAttachment? hasAttachment,
  }) {
    searchEmailFilter.value = searchEmailFilter.value.copyWith(
      from: from,
      to: to,
      text: text,
      subject: subject,
      hasKeyword: hasKeyword,
      notKeyword: notKeyword,
      mailBoxId: mailBoxId,
      emailReceiveTimeType: emailReceiveTimeType,
      hasAttachment: hasAttachment,
    );
  }

  void registerSearchFocusListener() {
    searchFocus.addListener(() {
      final hasFocus = searchFocus.hasFocus;
      final query = searchEmailFilter.value.text?.value;
      log('MailboxDashBoardController::_registerSearchFocusListener(): hasFocus: $hasFocus | query: $query');
      if (!hasFocus && (query == null || query.isEmpty)) {
        disableSearch();
      }
    });
  }

  bool isSearchActive() =>
      searchState.value.searchStatus == SearchStatus.ACTIVE;

  void enableSearch() {
    searchState.value = searchState.value.enableSearchState();
  }

  void disableSearch() {
    searchState.value = searchState.value.disableSearchState();
    updateFilterEmail(text: SearchQuery.initial());
    searchInputController.clear();
    cleanSearchFilter();
    searchFocus.unfocus();
  }

  void clearTextSearch() {
    updateFilterEmail(text: SearchQuery.initial());
    searchInputController.clear();
    searchFocus.requestFocus();
  }

  void onChangeTextSearch(String value) {
    updateFilterEmail(text: SearchQuery(value));
  }

  void updateTextSearch(String value) {
    searchInputController.text = value;
  }

  bool checkQuickSearchFilterSelected(
      QuickSearchFilter quickSearchFilter, UserProfile userProfile,bool fromSuggestBox) {
    switch (quickSearchFilter) {
      case QuickSearchFilter.hasAttachment:
        return searchEmailFilter.value.hasAttachment == HasAttachment.yes;
      case QuickSearchFilter.last7Days:
        if(fromSuggestBox){
          return searchEmailFilter.value.emailReceiveTimeType !=null;
        }
        return searchEmailFilter.value.emailReceiveTimeType ==
            EmailReceiveTimeType.last7Days;
      case QuickSearchFilter.fromMe:
        return searchEmailFilter.value.from.contains(userProfile.email) &&
            searchEmailFilter.value.from.length == 1;
    }
  }

  @override
  void onDone() {}

  @override
  void onError(error) {}

  @override
  void onClose() {
    searchInputController.dispose();
    searchFocus.dispose();
    super.onClose();
  }
}
