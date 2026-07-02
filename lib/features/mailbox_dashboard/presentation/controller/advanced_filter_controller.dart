import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/labels.dart';
import 'package:model/model.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/input_field_focus_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart' as search;
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AdvancedFilterController extends BaseController {
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;

  final receiveTimeType = EmailReceiveTimeType.allTime.obs;
  final hasAttachment = false.obs;
  final isStarred = false.obs;
  final isUnread = false.obs;
  final notIncludeEvents = false.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final sortOrderType = SearchEmailFilter.defaultSortOrder.obs;
  final destinationMailboxSelected = Rxn<PresentationMailbox>();
  final selectedLabel = Rxn<Label>();

  final GlobalKey<TagsEditorState> keyFromEmailTagEditor = GlobalKey<TagsEditorState>();
  final GlobalKey<TagsEditorState> keyToEmailTagEditor = GlobalKey<TagsEditorState>();
  final fromAddressExpandMode = ExpandMode.EXPAND.obs;
  final toAddressExpandMode = ExpandMode.EXPAND.obs;

  List<EmailAddress> listFromEmailAddress = <EmailAddress>[];
  List<EmailAddress> listToEmailAddress = <EmailAddress>[];

  TextEditingController fromEmailAddressController = TextEditingController();
  TextEditingController toEmailAddressController = TextEditingController();
  TextEditingController subjectFilterInputController = TextEditingController();
  TextEditingController hasKeyWordFilterInputController = TextEditingController();
  TextEditingController notKeyWordFilterInputController = TextEditingController();

  final search.SearchController searchController = Get.find<search.SearchController>();
  final MailboxDashBoardController _mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  final focusManager = InputFieldFocusManager.initial();

  late Worker _dashboardActionWorker;

  /// The advanced form reads and writes the committed filter directly, so field
  /// edits sync live to the suggestion chips and result chips (no draft staging).
  SearchEmailFilter get _committedFilter =>
      appProviderContainer.read(searchFilterProvider);

  @override
  void onInit() {
    _registerWorkerListener();
    _registerFocusListener();
    super.onInit();
  }

  @override
  void onReady() {
    injectAutoCompleteBindings(
      _mailboxDashBoardController.sessionCurrent,
      _mailboxDashBoardController.accountId.value);
    _setUpDefaultSortOrder(_mailboxDashBoardController.currentSortOrder);
    super.onReady();
  }

  void _setUpDefaultSortOrder(EmailSortOrderType emailSortOrderType) {
    sortOrderType.value = emailSortOrderType;
    // Sync only the sort field so any filters already committed by other search
    // surfaces are preserved.
    _updateCommittedFilter(sortOrderTypeOption: Some(emailSortOrderType));
  }

  void _updateSortOrder(EmailSortOrderType emailSortOrderType) {
    sortOrderType.value = emailSortOrderType;
    _updateCommittedFilter(sortOrderTypeOption: Some(emailSortOrderType));
  }

  void clearSearchFilter() {
    appProviderContainer.read(searchFilterProvider.notifier).clear();
    _resetAllToOriginalValue();
    _clearAllTextFieldInput();
    _mailboxDashBoardController.handleClearAdvancedSearchFilterEmail();
  }

  @visibleForTesting
  void setDestinationMailboxSelected(PresentationMailbox? presentationMailbox) {
    destinationMailboxSelected.value = presentationMailbox;
  }

  MailboxDashBoardController get mailboxDashBoardController => _mailboxDashBoardController;

  void _updateCommittedFilter({
    Option<Set<String>>? fromOption,
    Option<Set<String>>? toOption,
    Option<SearchQuery>? textOption,
    Option<String>? subjectOption,
    Option<Set<String>>? hasKeywordOption,
    Option<Set<String>>? notKeywordOption,
    Option<PresentationMailbox>? mailboxOption,
    Option<EmailReceiveTimeType>? emailReceiveTimeTypeOption,
    Option<bool>? hasAttachmentOption,
    Option<bool>? unreadOption,
    Option<bool>? notIncludeEventsOption,
    Option<UTCDate>? startDateOption,
    Option<UTCDate>? endDateOption,
    Option<EmailSortOrderType>? sortOrderTypeOption,
    Option<Label>? labelOption,
  }) {
    appProviderContainer.read(searchFilterProvider.notifier).update(
          fromOption: fromOption,
          toOption: toOption,
          textOption: textOption,
          subjectOption: subjectOption,
          hasKeywordOption: hasKeywordOption,
          notKeywordOption: notKeywordOption,
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

  void _syncFormToCommitted() {
    final textOption = option(
      hasKeyWordFilterInputController.text.trim().isNotEmpty,
      SearchQuery(hasKeyWordFilterInputController.text.trim()));

    final notKeywordsOption = option(
      notKeyWordFilterInputController.text.trim().isNotEmpty,
      notKeyWordFilterInputController.text.trim().split(',').map((value) => value.trim()).toSet());

    final fromOption = option(
      listFromEmailAddress.isNotEmpty,
      listFromEmailAddress.asSetAddress());

    final toOption = option(
      listToEmailAddress.isNotEmpty,
      listToEmailAddress.asSetAddress());

    final sortOrderTypeOption = Some(sortOrderType.value);

    final mailboxOption = optionOf(destinationMailboxSelected.value);

    final subjectOption = option(
      subjectFilterInputController.text.trim().isNotEmpty,
      subjectFilterInputController.text.trim());

    final emailReceiveTimeTypeOption = Some(receiveTimeType.value);

    final hasAttachmentOption = Some(hasAttachment.value);

    final Option<UTCDate> startDateOption;
    final Option<UTCDate> endDateOption;
    if (receiveTimeType.value == EmailReceiveTimeType.customRange) {
      startDateOption = optionOf(startDate.value?.toUTCDate());
      endDateOption = optionOf(endDate.value?.toUTCDate());
    } else {
      final dateRange = receiveTimeType.value.toDateRange();
      startDateOption = optionOf(dateRange.start);
      endDateOption = optionOf(dateRange.end);
    }

    final unreadOption = Some(isUnread.value);

    final notIncludeEventsOption = Some(notIncludeEvents.value);

    final listKeywords = {
      if (isStarred.isTrue) KeyWordIdentifier.emailFlagged.value,
    };
    final hasKeywordOption =
        optionOf(listKeywords.isNotEmpty ? listKeywords : null);

    final labelOption = optionOf(selectedLabel.value);

    _updateCommittedFilter(
      textOption: textOption,
      notKeywordOption: notKeywordsOption,
      fromOption: fromOption,
      toOption: toOption,
      sortOrderTypeOption: sortOrderTypeOption,
      mailboxOption: mailboxOption,
      subjectOption: subjectOption,
      emailReceiveTimeTypeOption: emailReceiveTimeTypeOption,
      hasAttachmentOption: hasAttachmentOption,
      unreadOption: unreadOption,
      notIncludeEventsOption: notIncludeEventsOption,
      hasKeywordOption: hasKeywordOption,
      startDateOption: startDateOption,
      endDateOption: endDateOption,
      labelOption: labelOption,
    );
  }

  void selectedMailBox(BuildContext context) async {
    final accountId = _mailboxDashBoardController.accountId.value;
    final session = _mailboxDashBoardController.sessionCurrent;

    if (session == null || accountId == null) return;

    final arguments = DestinationPickerArguments(
      accountId,
      MailboxActions.select,
      session,
      mailboxIdSelected: destinationMailboxSelected.value?.id
    );

    final destinationMailbox = PlatformInfo.isWeb
      ? await DialogRouter().pushGeneralDialog(
          routeName: AppRoutes.destinationPicker,
          arguments: arguments)
      : await push(AppRoutes.destinationPicker, arguments: arguments);

    if (destinationMailbox is! PresentationMailbox) return;

    destinationMailboxSelected.value = destinationMailbox;
    _updateCommittedFilter(mailboxOption: optionOf(destinationMailbox));
  }

  void applyAdvancedSearchFilter() {
    _syncFormToCommitted();
    final committed = _committedFilter;
    // Strip any pagination cursor before running a fresh search.
    appProviderContainer.read(searchFilterProvider.notifier).set(committed);
    if (committed.isApplied) {
      searchController.activateAdvancedSearch();
    } else {
      searchController.deactivateAdvancedSearch();
    }
    searchController.isAdvancedSearchViewOpen.value = false;
    _mailboxDashBoardController.handleAdvancedSearchEmail();
  }

  Future<List<EmailAddress>> getAutoCompleteSuggestion(String word, {int? limit}) async {
    log('AdvancedFilterController::getAutoCompleteSuggestion():word = $word | limit = $limit');
    _getAutoCompleteInteractor = getBinding<GetAutoCompleteInteractor>();

    return await _getAutoCompleteInteractor
      ?.execute(AutoCompletePattern(
          word: word,
          limit: limit,
          accountId: _mailboxDashBoardController.accountId.value,
      )).then((value) => value.fold(
        (failure) => <EmailAddress>[],
        (success) => success is GetAutoCompleteSuccess
          ? success.listEmailAddress
          : <EmailAddress>[]
      )) ?? [];
  }

  void initSearchFilterField(BuildContext? context) {
    subjectFilterInputController.text = StringConvert.writeNullToEmpty(
      _committedFilter.subject);

    hasKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(
      _committedFilter.text?.value);

    notKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(
      _committedFilter.notKeyword.join(','));

    receiveTimeType.value = _committedFilter.emailReceiveTimeType;

    startDate.value = _committedFilter.startDate?.value.toLocal();
    endDate.value = _committedFilter.endDate?.value.toLocal();

    sortOrderType.value = _committedFilter.sortOrderType;

    destinationMailboxSelected.value = _committedFilter.mailbox;

    hasAttachment.value = _committedFilter.hasAttachment;

    isUnread.value = _committedFilter.unread;

    isStarred.value = _committedFilter.hasKeyword
        .contains(KeyWordIdentifier.emailFlagged.value);

    notIncludeEvents.value = _committedFilter.notIncludeEvents;

    if (_committedFilter.from.isEmpty) {
      listFromEmailAddress.clear();
    } else {
      final listEmailAddress = _committedFilter.from
        .map((email) => EmailAddress(null, email));
      listFromEmailAddress = List.from(listEmailAddress);
      fromAddressExpandMode.value = ExpandMode.COLLAPSE;
    }

    if (_committedFilter.to.isEmpty) {
      listToEmailAddress.clear();
    } else {
      final listEmailAddress = _committedFilter.to
        .map((email) => EmailAddress(null, email));
      listToEmailAddress = List.from(listEmailAddress);
      toAddressExpandMode.value = ExpandMode.COLLAPSE;
    }

    selectedLabel.value = _committedFilter.label;
  }

  void selectDateRange(BuildContext context) {
    searchController.showMultipleViewDateRangePicker(
      context,
      startDate.value,
      endDate.value,
      onCallbackAction: (startDate, endDate) =>
        _updateDateRangeTime(
          EmailReceiveTimeType.customRange,
          newStartDate: startDate,
          newEndDate: endDate
        )
    );
  }

  void _updateDateRangeTime(EmailReceiveTimeType receiveTime, {DateTime? newStartDate, DateTime? newEndDate}) {
    startDate.value = newStartDate;
    endDate.value = newEndDate;
    receiveTimeType.value = receiveTime;

    if (receiveTime == EmailReceiveTimeType.customRange) {
      _updateCommittedFilter(
        emailReceiveTimeTypeOption: Some(receiveTime),
        startDateOption: optionOf(startDate.value?.toUTCDate()),
        endDateOption: optionOf(endDate.value?.toUTCDate()),
      );
    } else {
      final dateRange = receiveTime.toDateRange();
      _updateCommittedFilter(
        emailReceiveTimeTypeOption: Some(receiveTime),
        startDateOption: optionOf(dateRange.start),
        endDateOption: optionOf(dateRange.end),
      );
    }
  }

  void updateReceiveDateSearchFilter(BuildContext context, EmailReceiveTimeType receiveTime) {
    if (receiveTime == EmailReceiveTimeType.customRange) {
      searchController.showMultipleViewDateRangePicker(
        context,
        startDate.value,
        endDate.value,
        onCallbackAction: (startDate, endDate) =>
          _updateDateRangeTime(
            EmailReceiveTimeType.customRange,
            newStartDate: startDate,
            newEndDate: endDate
          )
      );
    } else {
      _updateDateRangeTime(receiveTime);
    }
  }

  void _onFromFieldFocusChange() {
    if (focusManager.fromFieldFocusNode.hasFocus) {
      fromAddressExpandMode.value = ExpandMode.EXPAND;
      toAddressExpandMode.value = ExpandMode.COLLAPSE;
      _closeSuggestionBox();
    } else {
      fromAddressExpandMode.value = ExpandMode.COLLAPSE;
      _autoCreateTagFromField();
    }
  }

  void _onToFieldFocusChange() {
    if (focusManager.toFieldFocusNode.hasFocus) {
      toAddressExpandMode.value = ExpandMode.EXPAND;
      fromAddressExpandMode.value = ExpandMode.COLLAPSE;
      _closeSuggestionBox();
    } else {
      toAddressExpandMode.value = ExpandMode.COLLAPSE;
      _autoCreateTagToField();
    }
  }

  void _closeSuggestionBox() {
    if (fromEmailAddressController.text.isNotEmpty) {
      keyFromEmailTagEditor.currentState?.closeSuggestionBox();
    }

    if (toEmailAddressController.text.isNotEmpty) {
      keyToEmailTagEditor.currentState?.closeSuggestionBox();
    }
  }

  void showFullEmailAddress(FilterField field) {
    FocusManager.instance.primaryFocus?.unfocus();

    switch(field) {
      case FilterField.from:
        fromAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      case FilterField.to:
        toAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      default:
        break;
    }
  }

  void updateListEmailAddress(
    FilterField field,
    List<EmailAddress> listEmailAddress,
  ) {
    switch(field) {
      case FilterField.from:
        listFromEmailAddress = List.from(listEmailAddress);
        _updateCommittedFilter(
          fromOption: option(
            listFromEmailAddress.isNotEmpty,
            listFromEmailAddress.asSetAddress()));
        break;
      case FilterField.to:
        listToEmailAddress = List.from(listEmailAddress);
        _updateCommittedFilter(
          toOption: option(
            listToEmailAddress.isNotEmpty,
            listToEmailAddress.asSetAddress()));
        break;
      default:
        break;
    }
  }

  void _autoCreateTagFromField() {
    final inputEmail = fromEmailAddressController.text;
    if (inputEmail.isEmpty) {
      return;
    }

    if (!listFromEmailAddress.isDuplicatedEmail(inputEmail)) {
      final emailAddress = EmailAddress(null, inputEmail);
      listFromEmailAddress.add(emailAddress);
      _updateCommittedFilter(fromOption: Some(listFromEmailAddress.asSetAddress()));
      keyFromEmailTagEditor.currentState?.resetTextField();
      Future.delayed(const Duration(milliseconds: 300), () {
        keyFromEmailTagEditor.currentState?.closeSuggestionBox();
      });
    }
  }

  void _autoCreateTagToField() {
    final inputEmail = toEmailAddressController.text;
    if (inputEmail.isEmpty) {
      return;
    }

    if (!listToEmailAddress.isDuplicatedEmail(inputEmail)) {
      listToEmailAddress.add(EmailAddress(null, inputEmail));
      _updateCommittedFilter(toOption: Some(listToEmailAddress.asSetAddress()));
      keyToEmailTagEditor.currentState?.resetTextField();
      Future.delayed(const Duration(milliseconds: 300), () {
        keyToEmailTagEditor.currentState?.closeSuggestionBox();
      });
    }
  }

  void updateSortOrder(EmailSortOrderType? sortOrder) {
    if (sortOrder != null) {
      sortOrderType.value = sortOrder;
      _updateCommittedFilter(sortOrderTypeOption: Some(sortOrder));
    }
  }

  void _resetAllToOriginalValue() {
    startDate.value = null;
    endDate.value = null;
    receiveTimeType.value = EmailReceiveTimeType.allTime;
    hasAttachment.value = false;
    isUnread.value = false;
    isStarred.value = false;
    notIncludeEvents.value = false;
    destinationMailboxSelected.value = null;
    listFromEmailAddress.clear();
    listToEmailAddress.clear();
    selectedLabel.value = null;
  }

  void _clearAllTextFieldInput() {
    subjectFilterInputController.clear();
    hasKeyWordFilterInputController.clear();
    notKeyWordFilterInputController.clear();
    fromEmailAddressController.clear();
    toEmailAddressController.clear();
  }

  void _registerWorkerListener() {
    _dashboardActionWorker = ever(
      _mailboxDashBoardController.dashBoardAction,
      (action) {
        log('AdvancedFilterController::_registerWorkerListener(): ${action.runtimeType}');
        if (action is ClearAllFieldOfAdvancedSearchAction) {
          _handleClearAllFieldOfAdvancedSearch();
        } else if (action is SelectDateRangeToAdvancedSearch) {
          _updateDateRangeTime(
            action.receiveTime,
            newStartDate: action.startDate,
            newEndDate: action.endDate
          );
        } else if (action is StartSearchEmailAction) {
          _handleStartSearchEmailAction();
        } else if (action is QuickSearchEmailByFromAction) {
          _handleQuickSearchEmailByFromAction(action.emailAddress);
        } else if (action is OpenAdvancedSearchViewAction) {
          initSearchFilterField(currentContext);
        } else if (action is ClearSearchFilterAppliedAction) {
          clearSearchFilter();
        } else if (action is SynchronizeEmailSortOrderAction) {
          _updateSortOrder(action.emailSortOrderType);
        }
      }
    );
  }

  void _registerFocusListener() {
    focusManager.fromFieldFocusNode.addListener(_onFromFieldFocusChange);
    focusManager.toFieldFocusNode.addListener(_onToFieldFocusChange);
  }

  void _unregisterWorkerListener() {
    _dashboardActionWorker.dispose();
  }

  void _removeFocusListener() {
    focusManager.fromFieldFocusNode.removeListener(_onFromFieldFocusChange);
    focusManager.toFieldFocusNode.removeListener(_onToFieldFocusChange);
  }

  void _handleClearAllFieldOfAdvancedSearch() {
    _resetAllToOriginalValue();
    _clearAllTextFieldInput();
    appProviderContainer.read(searchFilterProvider.notifier).clear();
  }

  void onSearchAction() {
    FocusManager.instance.primaryFocus?.unfocus();
    applyAdvancedSearchFilter();
  }

  void _handleStartSearchEmailAction() {
    initSearchFilterField(currentContext);
  }

  void onHasAttachmentCheckboxChanged(bool? isChecked) {
    hasAttachment.value = isChecked ?? false;
    _updateCommittedFilter(hasAttachmentOption: Some(hasAttachment.value));
  }

  void onStarredCheckboxChanged(bool? isChecked) {
    isStarred.value = isChecked ?? false;
    _updateKeywordsSearchFilter(
      isStarred.isTrue,
      KeyWordIdentifier.emailFlagged,
    );
  }

  void onUnreadCheckboxChanged(bool? isChecked) {
    isUnread.value = isChecked ?? false;
    _updateCommittedFilter(
      unreadOption: isUnread.isTrue ? const Some(true) : const None(),
    );
  }

  void _updateKeywordsSearchFilter(bool isChecked, KeyWordIdentifier keyword) {
    final listHasKeywordFiltered = Set<String>.of(_committedFilter.hasKeyword);
    if (isChecked) {
      listHasKeywordFiltered.add(keyword.value);
    } else {
      listHasKeywordFiltered.remove(keyword.value);
    }
    _updateCommittedFilter(
      hasKeywordOption: Some(listHasKeywordFiltered),
    );
  }

  void onEventsCheckboxChanged(bool? isChecked) {
    notIncludeEvents.value = isChecked ?? false;
    _updateCommittedFilter(
      notIncludeEventsOption: notIncludeEvents.isTrue ? const Some(true) : const None(),
    );
  }

  void onTextChanged(FilterField filterField, String value) {
    switch (filterField) {
      case FilterField.subject:
        final subjectOption = option(value.trim().isNotEmpty, value.trim());
        _updateCommittedFilter(subjectOption: subjectOption);
        break;
      case FilterField.hasKeyword:
        final textOption = option(
          value.trim().isNotEmpty,
          SearchQuery(value.trim()));
        _updateCommittedFilter(textOption: textOption);
        break;
      case FilterField.notKeyword:
        final notKeywordsOption = option(
          value.trim().isNotEmpty,
          value.trim().split(',').map((value) => value.trim()).toSet());
        _updateCommittedFilter(notKeywordOption: notKeywordsOption);
        break;
      default:
        break;
    }
  }

  void removeDraggableEmailAddress(DraggableEmailAddress draggableEmailAddress) {
    log('AdvancedFilterController::removeDraggableEmailAddress:removeDraggableEmailAddress: $draggableEmailAddress');
    switch(draggableEmailAddress.filterField) {
      case FilterField.to:
        listToEmailAddress.remove(draggableEmailAddress.emailAddress);
        _updateCommittedFilter(
          toOption: option(
            listToEmailAddress.isNotEmpty,
            listToEmailAddress.asSetAddress(),
          ),
        );
        toAddressExpandMode.value = ExpandMode.EXPAND;
        toAddressExpandMode.refresh();
        break;
      case FilterField.from:
        listFromEmailAddress.remove(draggableEmailAddress.emailAddress);
        _updateCommittedFilter(
          fromOption: option(
            listFromEmailAddress.isNotEmpty,
            listFromEmailAddress.asSetAddress(),
          ),
        );
        fromAddressExpandMode.value = ExpandMode.EXPAND;
        fromAddressExpandMode.refresh();
        break;
      default:
        break;
    }
  }

  void _handleQuickSearchEmailByFromAction(EmailAddress emailAddress) {
    searchController.clearSearchFilter(sortOrderType: sortOrderType.value);
    _resetAllToOriginalValue();
    _clearAllTextFieldInput();
    searchController.searchInputController.clear();
    searchController.deactivateAdvancedSearch();
    searchController.isAdvancedSearchViewOpen.value = false;
    listFromEmailAddress = List.from({emailAddress});
    _updateCommittedFilter(fromOption: Some(listFromEmailAddress.asSetAddress()));
    _mailboxDashBoardController.dispatchAction(StartSearchEmailAction());
  }

  @override
  void onClose() {
    _removeFocusListener();
    focusManager.dispose();
    subjectFilterInputController.dispose();
    hasKeyWordFilterInputController.dispose();
    notKeyWordFilterInputController.dispose();
    toEmailAddressController.dispose();
    fromEmailAddressController.dispose();
    _unregisterWorkerListener();
    _resetAllToOriginalValue();
    super.onClose();
  }
}
