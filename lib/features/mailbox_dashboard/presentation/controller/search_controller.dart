import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/wrapper_utils.dart';
import 'package:core/presentation/views/bottom_popup/full_screen_action_sheet_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search_input_form.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';

class SearchController extends BaseController {
  final QuickSearchEmailInteractor _quickSearchEmailInteractor;

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final searchEmailFilter = SearchEmailFilter().obs;
  final searchState = SearchState.initial().obs;
  final isAdvancedSearchViewOpen = false.obs;
  final dateFilterSelectedFormAdvancedSearch = EmailReceiveTimeType.anyTime.obs;
  final mailboxFilterSelectedFormAdvancedSearch = Rxn<PresentationMailbox>();
  final hasAttachment = false.obs;

  late AccountId _accountId;
  late UserProfile _userProfile;

  TextEditingController searchInputController = TextEditingController();
  TextEditingController fromFilterInputController = TextEditingController();
  TextEditingController toFilterInputController = TextEditingController();
  TextEditingController subjectFilterInputController = TextEditingController();
  TextEditingController hasKeyWordFilterInputController = TextEditingController();
  TextEditingController notKeyWordFilterInputController = TextEditingController();
  TextEditingController dateFilterInputController = TextEditingController();
  TextEditingController mailBoxFilterInputController = TextEditingController();

  FocusNode searchFocus = FocusNode();

  SearchEmailFilter get searchEmailFilterValue => searchEmailFilter.value;

  SearchController(
    this._quickSearchEmailInteractor,
  );

  selectOpenAdvanceSearch() {
    isAdvancedSearchViewOpen.value = !isAdvancedSearchViewOpen.value;
  }

  void setAccountId(AccountId accountId) {
    _accountId = accountId;
  }

  void setUserProfile(UserProfile userProfile) {
    _userProfile = userProfile;
  }

  showAdvancedFilterView(BuildContext context) async {
    selectOpenAdvanceSearch();
    if (_responsiveUtils.isMobile(context)) {
      await FullScreenActionSheetBuilder(
        context: context,
        child: AdvancedSearchInputForm(),
        cancelWidget: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: SvgPicture.asset(
            _imagePaths.icCloseAdvancedSearch,
            color: AppColor.colorHintSearchBar,
            width: 24,
            height: 24,
          ),
        ),
        titleWidget: const Text(
          'Advanced search',
          style: TextStyle(
            fontSize: 20,
            color: AppColor.colorNameEmail,
          ),
        ),
      ).show();
      selectOpenAdvanceSearch();
    }
  }

  cleanSearchFilter() {
    searchEmailFilter.value = SearchEmailFilter();
  }

  initSearchFilterField(BuildContext context) {
    fromFilterInputController.text = _writeNullToEmpty(searchEmailFilter.value.from.firstOrNull);
    toFilterInputController.text = _writeNullToEmpty(searchEmailFilter.value.to.firstOrNull);
    subjectFilterInputController.text = _writeNullToEmpty(searchEmailFilter.value.subject);
    hasKeyWordFilterInputController.text = _writeNullToEmpty(searchEmailFilter.value.hasKeyword);
    notKeyWordFilterInputController.text = _writeNullToEmpty(searchEmailFilter.value.notKeyword);
    dateFilterInputController.text = _writeNullToEmpty(searchEmailFilter.value.emailReceiveTimeType.getTitle(context));
    mailBoxFilterInputController.text = _writeNullToEmpty(searchEmailFilter.value.mailbox?.name?.name);
    dateFilterSelectedFormAdvancedSearch.value = searchEmailFilter.value.emailReceiveTimeType;
    mailboxFilterSelectedFormAdvancedSearch.value = searchEmailFilter.value.mailbox;
    hasAttachment.value = searchEmailFilter.value.hasAttachment;
  }

  String? _writeEmptyToNull(String text) {
    if (text.isEmpty) return null;
    return text;
  }

  String _writeNullToEmpty(String? text) {
    return text ?? '';
  }

  void selectQuickSearchFilter({
    required QuickSearchFilter quickSearchFilter,
    bool fromSuggestionBox = false,
  }) {
    final isSelected = checkQuickSearchFilterSelected(
      quickSearchFilter,
      fromSuggestionBox,
    );

    switch (quickSearchFilter) {
      case QuickSearchFilter.hasAttachment:
        updateFilterEmail(hasAttachment: !isSelected);
        return;
      case QuickSearchFilter.last7Days:
        final EmailReceiveTimeType? emailReceiveTimeType = isSelected
            ? EmailReceiveTimeType.anyTime
            : EmailReceiveTimeType.last7Days;
        updateFilterEmail(emailReceiveTimeType: emailReceiveTimeType);
        return;
      case QuickSearchFilter.fromMe:
        isSelected
            ? searchEmailFilter.value.from.remove(_userProfile.email)
            : searchEmailFilter.value.from.add(_userProfile.email);
        updateFilterEmail(from: searchEmailFilter.value.from);
        return;
    }
  }

  Future<List<PresentationEmail>> quickSearchEmails() async {
    return await _quickSearchEmailInteractor
        .execute(_accountId,
            limit: UnsignedInt(5),
            sort: <Comparator>{}..add(
                EmailComparator(EmailComparatorProperty.receivedAt)
                  ..setIsAscending(false)),
            filter: searchEmailFilter.value.mappingToEmailFilterCondition(),
            properties: ThreadConstants.propertiesQuickSearch)
        .then((result) => result.fold(
            (failure) => <PresentationEmail>[],
            (success) => success is QuickSearchEmailSuccess
                ? success.emailList
                : <PresentationEmail>[]));
  }

  void updateFilterEmailFromAdvancedSearchView() {
    if (fromFilterInputController.text.isNotEmpty) {
      searchEmailFilter.value.from.add(fromFilterInputController.text);
    }
    if (toFilterInputController.text.isNotEmpty) {
      searchEmailFilter.value.to.add(toFilterInputController.text);
    }
    searchEmailFilter.value = searchEmailFilter.value.copyWith(
      subject: _writeEmptyToNull(subjectFilterInputController.text),
      hasKeyword: Wrapped.value(
          _writeEmptyToNull(hasKeyWordFilterInputController.text)),
      notKeyword: Wrapped.value(
          _writeEmptyToNull(notKeyWordFilterInputController.text)),
      mailbox: mailboxFilterSelectedFormAdvancedSearch.value,
      emailReceiveTimeType: dateFilterSelectedFormAdvancedSearch.value,
      hasAttachment: hasAttachment.value,
    );
  }

  void updateFilterEmail({
    Set<String>? from,
    Set<String>? to,
    SearchQuery? text,
    String? subject,
    Wrapped<String?>? hasKeyword,
    Wrapped<String?>? notKeyword,
    PresentationMailbox? mailbox,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
  }) {
    searchEmailFilter.value = searchEmailFilter.value.copyWith(
      from: from,
      to: to,
      text: text,
      subject: subject,
      hasKeyword: hasKeyword,
      notKeyword: notKeyword,
      mailbox: mailbox,
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
        updateFilterEmail(text: SearchQuery.initial());
        searchInputController.clear();
        cleanSearchFilter();
        searchFocus.unfocus();      }
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
      QuickSearchFilter quickSearchFilter, bool fromSuggestBox) {
    switch (quickSearchFilter) {
      case QuickSearchFilter.hasAttachment:
        return searchEmailFilter.value.hasAttachment == true;
      case QuickSearchFilter.last7Days:
        if (fromSuggestBox) {
          return true;
        }
        return searchEmailFilter.value.emailReceiveTimeType ==
            EmailReceiveTimeType.last7Days;
      case QuickSearchFilter.fromMe:
        return searchEmailFilter.value.from.contains(_userProfile.email) &&
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
    fromFilterInputController.dispose();
    subjectFilterInputController.dispose();
    toFilterInputController.dispose();
    hasKeyWordFilterInputController.dispose();
    notKeyWordFilterInputController.dispose();
    mailBoxFilterInputController.dispose();
    dateFilterInputController.dispose();
    searchFocus.dispose();
    super.onClose();
  }
}
