import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/input_field_focus_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart' as search;
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AdvancedFilterController extends BaseController {
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;

  final receiveTimeType = EmailReceiveTimeType.allTime.obs;
  final hasAttachment = false.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final sortOrderType = EmailSortOrderType.mostRecent.obs;

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
  TextEditingController mailBoxFilterInputController = TextEditingController();

  final search.SearchController searchController = Get.find<search.SearchController>();
  final MailboxDashBoardController _mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  final focusManager = InputFieldFocusManager.initial();
  SearchEmailFilter _memorySearchFilter = SearchEmailFilter.initial();

  PresentationMailbox? _destinationMailboxSelected;

  late Worker _dashboardActionWorker;

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
    super.onReady();
  }

  void clearSearchFilter() {
    _memorySearchFilter = SearchEmailFilter.initial();
    _resetAllToOriginalValue();
    _clearAllTextFieldInput();
    _mailboxDashBoardController.handleClearAdvancedSearchFilterEmail();
  }

  @visibleForTesting
  void setDestinationMailboxSelected(PresentationMailbox? presentationMailbox) {
    _destinationMailboxSelected = presentationMailbox;
  }

  @visibleForTesting
  SearchEmailFilter get memorySearchFilter => _memorySearchFilter;

  @visibleForTesting
  void setMemorySearchFilter(SearchEmailFilter searchFilter) {
    _memorySearchFilter = searchFilter;
  }

  MailboxDashBoardController get mailboxDashBoardController => _mailboxDashBoardController;

  void _updateMemorySearchFilter({
    Option<Set<String>>? fromOption,
    Option<Set<String>>? toOption,
    Option<SearchQuery>? textOption,
    Option<String>? subjectOption,
    Option<Set<String>>? notKeywordOption,
    Option<PresentationMailbox>? mailboxOption,
    Option<EmailReceiveTimeType>? emailReceiveTimeTypeOption,
    Option<bool>? hasAttachmentOption,
    Option<UTCDate>? beforeOption,
    Option<UTCDate>? startDateOption,
    Option<UTCDate>? endDateOption,
    Option<int>? positionOption,
    Option<EmailSortOrderType>? sortOrderTypeOption,
  }) {
    _memorySearchFilter = _memorySearchFilter.copyWith(
      fromOption: fromOption,
      toOption: toOption,
      textOption: textOption,
      subjectOption: subjectOption,
      notKeywordOption: notKeywordOption,
      mailboxOption: mailboxOption,
      emailReceiveTimeTypeOption: emailReceiveTimeTypeOption,
      hasAttachmentOption: hasAttachmentOption,
      beforeOption: beforeOption,
      startDateOption: startDateOption,
      endDateOption: endDateOption,
      positionOption: positionOption,
      sortOrderTypeOption: sortOrderTypeOption);
  }

  void _synchronizeSearchFilter() {
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

    final mailboxOption = optionOf(_destinationMailboxSelected);

    final subjectOption = option(
      subjectFilterInputController.text.trim().isNotEmpty,
      subjectFilterInputController.text.trim());

    final emailReceiveTimeTypeOption = Some(receiveTimeType.value);

    final hasAttachmentOption = Some(hasAttachment.value);

    final startDateOption = optionOf(startDate.value?.toUTCDate());

    final endDateOption = optionOf(endDate.value?.toUTCDate());

    _updateMemorySearchFilter(
      textOption: textOption,
      notKeywordOption: notKeywordsOption,
      fromOption: fromOption,
      toOption: toOption,
      sortOrderTypeOption: sortOrderTypeOption,
      mailboxOption: mailboxOption,
      subjectOption: subjectOption,
      emailReceiveTimeTypeOption: emailReceiveTimeTypeOption,
      hasAttachmentOption: hasAttachmentOption,
      startDateOption: startDateOption,
      endDateOption: endDateOption
    );

    searchController.synchronizeSearchFilter(_memorySearchFilter);
  }

  void selectedMailBox(BuildContext context) async {
    final accountId = _mailboxDashBoardController.accountId.value;
    final session = _mailboxDashBoardController.sessionCurrent;

    if (session == null || accountId == null) return;

    final arguments = DestinationPickerArguments(
      accountId,
      MailboxActions.select,
      session,
      mailboxIdSelected: _destinationMailboxSelected?.id
    );

    final destinationMailbox = PlatformInfo.isWeb
      ? await DialogRouter.pushGeneralDialog(
          routeName: AppRoutes.destinationPicker,
          arguments: arguments)
      : await push(AppRoutes.destinationPicker, arguments: arguments);

    if (destinationMailbox is! PresentationMailbox) return;

    _destinationMailboxSelected = destinationMailbox;
    final mailboxName = context.mounted
      ? _destinationMailboxSelected?.getDisplayName(context)
      : _destinationMailboxSelected?.name?.name;
    mailBoxFilterInputController.text = StringConvert.writeNullToEmpty(mailboxName);
    _updateMemorySearchFilter(mailboxOption: optionOf(_destinationMailboxSelected));
  }

  void applyAdvancedSearchFilter() {
    _synchronizeSearchFilter();
    if (searchController.searchEmailFilter.value.isApplied) {
      searchController.activateAdvancedSearch();
    } else {
      searchController.deactivateAdvancedSearch();
      searchController.updateFilterEmail(beforeOption: const None());
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
      _memorySearchFilter.subject);

    hasKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(
      _memorySearchFilter.text?.value);

    notKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(
      _memorySearchFilter.notKeyword.join(','));

    receiveTimeType.value = _memorySearchFilter.emailReceiveTimeType;

    sortOrderType.value = _memorySearchFilter.sortOrderType;

    _destinationMailboxSelected = _memorySearchFilter.mailbox;

    hasAttachment.value = _memorySearchFilter.hasAttachment;

    if (_memorySearchFilter.from.isEmpty) {
      listFromEmailAddress.clear();
    } else {
      final listEmailAddress = _memorySearchFilter.from
        .map((email) => EmailAddress(null, email));
      listFromEmailAddress = List.from(listEmailAddress);
      fromAddressExpandMode.value = ExpandMode.COLLAPSE;
    }

    if (_memorySearchFilter.to.isEmpty) {
      listToEmailAddress.clear();
    } else {
      final listEmailAddress = _memorySearchFilter.to
        .map((email) => EmailAddress(null, email));
      listToEmailAddress = List.from(listEmailAddress);
      toAddressExpandMode.value = ExpandMode.COLLAPSE;
    }

    if (context != null) {
      mailBoxFilterInputController.text = _memorySearchFilter.mailbox == null
        ? AppLocalizations.of(context).allFolders
        : StringConvert.writeNullToEmpty(
            _memorySearchFilter.mailbox?.getDisplayName(context));
    }
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

    _updateMemorySearchFilter(
      emailReceiveTimeTypeOption: Some(receiveTimeType.value),
      startDateOption: optionOf(startDate.value?.toUTCDate()),
      endDateOption: optionOf(endDate.value?.toUTCDate())
    );
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

  void showFullEmailAddress(AdvancedSearchFilterField field) {
    FocusManager.instance.primaryFocus?.unfocus();

    switch(field) {
      case AdvancedSearchFilterField.from:
        fromAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      case AdvancedSearchFilterField.to:
        toAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      default:
        break;
    }
  }

  void updateListEmailAddress(
    AdvancedSearchFilterField field,
    List<EmailAddress> listEmailAddress,
  ) {
    switch(field) {
      case AdvancedSearchFilterField.from:
        listFromEmailAddress = List.from(listEmailAddress);
        _updateMemorySearchFilter(
          fromOption: option(
            listFromEmailAddress.isNotEmpty,
            listFromEmailAddress.asSetAddress()));
        break;
      case AdvancedSearchFilterField.to:
        listToEmailAddress = List.from(listEmailAddress);
        _updateMemorySearchFilter(
          toOption: option(
            listToEmailAddress.isNotEmpty,
            listToEmailAddress.asSetAddress()));
        break;
      default:
        break;
    }
  }

  bool _isDuplicatedEmailAddress(String inputEmail, List<EmailAddress> listEmailAddress) {
    return listEmailAddress
      .map((emailAddress) => emailAddress.email)
      .whereNotNull()
      .contains(inputEmail);
  }

  void _autoCreateTagFromField() {
    final inputEmail = fromEmailAddressController.text;
    if (inputEmail.isEmpty) {
      return;
    }

    if (!_isDuplicatedEmailAddress(inputEmail, listFromEmailAddress)) {
      final emailAddress = EmailAddress(null, inputEmail);
      listFromEmailAddress.add(emailAddress);
      _updateMemorySearchFilter(fromOption: Some(listFromEmailAddress.asSetAddress()));
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

    if (!_isDuplicatedEmailAddress(inputEmail, listToEmailAddress)) {
      listToEmailAddress.add(EmailAddress(null, inputEmail));
      _updateMemorySearchFilter(toOption: Some(listToEmailAddress.asSetAddress()));
      keyToEmailTagEditor.currentState?.resetTextField();
      Future.delayed(const Duration(milliseconds: 300), () {
        keyToEmailTagEditor.currentState?.closeSuggestionBox();
      });
    }
  }

  void updateSortOrder(EmailSortOrderType? sortOrder) {
    if (sortOrder != null) {
      sortOrderType.value = sortOrder;
      _updateMemorySearchFilter(sortOrderTypeOption: Some(sortOrder));
    }
  }

  void _resetAllToOriginalValue() {
    startDate.value = null;
    endDate.value = null;
    receiveTimeType.value = EmailReceiveTimeType.allTime;
    hasAttachment.value = false;
    listFromEmailAddress.clear();
    listToEmailAddress.clear();
    _destinationMailboxSelected = null;
  }

  void _clearAllTextFieldInput() {
    subjectFilterInputController.clear();
    hasKeyWordFilterInputController.clear();
    notKeyWordFilterInputController.clear();
    mailBoxFilterInputController.clear();
    fromEmailAddressController.clear();
    toEmailAddressController.clear();
  }

  void _registerWorkerListener() {
    _dashboardActionWorker = ever(
      _mailboxDashBoardController.dashBoardAction,
      (action) {
        if (action is ClearAllFieldOfAdvancedSearchAction) {
          _handleClearAllFieldOfAdvancedSearch();
        } else if (action is SelectDateRangeToAdvancedSearch) {
          _updateDateRangeTime(
            EmailReceiveTimeType.customRange,
            newStartDate: action.startDate,
            newEndDate: action.endDate
          );
        } else if (action is ClearDateRangeToAdvancedSearch) {
          _updateDateRangeTime(action.receiveTime);
        } else if (action is StartSearchEmailAction) {
          _handleStartSearchEmailAction();
        } else if (action is QuickSearchEmailByFromAction) {
          _handleQuickSearchEmailByFromAction(action.emailAddress);
        } else if (action is OpenAdvancedSearchViewAction) {
          initSearchFilterField(currentContext);
        } else if (action is ClearSearchFilterAppliedAction) {
          clearSearchFilter();
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
    _memorySearchFilter = SearchEmailFilter.initial();
  }

  void onSearchAction() {
    FocusManager.instance.primaryFocus?.unfocus();
    applyAdvancedSearchFilter();
  }

  void _handleStartSearchEmailAction() {
    _memorySearchFilter = searchController.searchEmailFilter.value;
    initSearchFilterField(currentContext);
  }

  void onHasAttachmentCheckboxChanged(bool? isChecked) {
    hasAttachment.value = isChecked ?? false;
    _updateMemorySearchFilter(hasAttachmentOption: Some(hasAttachment.value));
  }

  void onTextChanged(AdvancedSearchFilterField filterField, String value) {
    switch (filterField) {
      case AdvancedSearchFilterField.subject:
        final subjectOption = option(value.trim().isNotEmpty, value.trim());
        _updateMemorySearchFilter(subjectOption: subjectOption);
        break;
      case AdvancedSearchFilterField.hasKeyword:
        final textOption = option(
          value.trim().isNotEmpty,
          SearchQuery(value.trim()));
        _updateMemorySearchFilter(textOption: textOption);
        break;
      case AdvancedSearchFilterField.notKeyword:
        final notKeywordsOption = option(
          value.trim().isNotEmpty,
          value.trim().split(',').map((value) => value.trim()).toSet());
        _updateMemorySearchFilter(notKeywordOption: notKeywordsOption);
        break;
      default:
        break;
    }
  }

  void removeDraggableEmailAddress(DraggableEmailAddress draggableEmailAddress) {
    log('AdvancedFilterController::removeDraggableEmailAddress:removeDraggableEmailAddress: $draggableEmailAddress');
    switch(draggableEmailAddress.prefix) {
      case PrefixEmailAddress.to:
        listToEmailAddress.remove(draggableEmailAddress.emailAddress);
        toAddressExpandMode.value = ExpandMode.EXPAND;
        toAddressExpandMode.refresh();
        break;
      case PrefixEmailAddress.from:
        listFromEmailAddress.remove(draggableEmailAddress.emailAddress);
        fromAddressExpandMode.value = ExpandMode.EXPAND;
        fromAddressExpandMode.refresh();
        break;
      default:
        break;
    }
  }

  void _handleQuickSearchEmailByFromAction(EmailAddress emailAddress) {
    searchController.clearSearchFilter();
    _memorySearchFilter = SearchEmailFilter.initial();
    _resetAllToOriginalValue();
    _clearAllTextFieldInput();
    searchController.searchInputController.clear();
    searchController.deactivateAdvancedSearch();
    searchController.isAdvancedSearchViewOpen.value = false;
    listFromEmailAddress = List.from({emailAddress});
    searchController.updateFilterEmail(fromOption: Some(listFromEmailAddress.asSetAddress()));
    _updateMemorySearchFilter(fromOption: Some(listFromEmailAddress.asSetAddress()));
    _mailboxDashBoardController.dispatchAction(StartSearchEmailAction());
  }

  @override
  void onClose() {
    _removeFocusListener();
    focusManager.dispose();
    subjectFilterInputController.dispose();
    hasKeyWordFilterInputController.dispose();
    notKeyWordFilterInputController.dispose();
    mailBoxFilterInputController.dispose();
    toEmailAddressController.dispose();
    fromEmailAddressController.dispose();
    _unregisterWorkerListener();
    _resetAllToOriginalValue();
    _memorySearchFilter = SearchEmailFilter.initial();
    super.onClose();
  }
}
