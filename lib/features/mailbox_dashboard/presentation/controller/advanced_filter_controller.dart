import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AdvancedFilterController extends BaseController {
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;

  final dateFilterSelectedFormAdvancedSearch = EmailReceiveTimeType.allTime.obs;
  final hasAttachment = false.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

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

  SearchEmailFilter get searchEmailFilter =>
      searchController.searchEmailFilter.value;

  final focusManager = InputFieldFocusManager.initial();

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
    _resetAllToOriginalValue();
    _clearAllTextFieldInput();
    _mailboxDashBoardController.handleClearAdvancedSearchFilterEmail();
  }

  void _updateFilterEmailFromAdvancedSearchView() {
    if (hasKeyWordFilterInputController.text.isNotEmpty) {
      searchController.updateFilterEmail(
        textOption: Some(SearchQuery(hasKeyWordFilterInputController.text)));
      searchController.searchInputController.text = hasKeyWordFilterInputController.text;
    } else {
      searchController.updateFilterEmail(
        textOption: Some(SearchQuery.initial()));
    }

    if (notKeyWordFilterInputController.text.isNotEmpty) {
      searchController.updateFilterEmail(
        notKeywordOption: Some(notKeyWordFilterInputController.text.split(',').toSet()));
    } else {
      searchController.updateFilterEmail(notKeywordOption: const None());
    }

    if (listFromEmailAddress.isNotEmpty) {
      final listAddress = listFromEmailAddress.map((emailAddress) => emailAddress.emailAddress).toSet();
      searchController.updateFilterEmail(fromOption: Some(listAddress));
    } else {
      searchController.updateFilterEmail(fromOption: const None());
    }
    if (listToEmailAddress.isNotEmpty) {
      final listAddress = listToEmailAddress.map((emailAddress) => emailAddress.emailAddress).toSet();
      searchController.updateFilterEmail(toOption: Some(listAddress));
    } else {
      searchController.updateFilterEmail(toOption: const None());
    }

    searchController.updateFilterEmail(
      mailboxOption: optionOf(_destinationMailboxSelected),
      subjectOption: optionOf(subjectFilterInputController.text),
      emailReceiveTimeTypeOption: optionOf(dateFilterSelectedFormAdvancedSearch.value),
      hasAttachmentOption: optionOf(hasAttachment.value),
      startDateOption: optionOf(startDate.value?.toUTCDate()),
      endDateOption: optionOf(endDate.value?.toUTCDate())
    );
  }

  void selectedMailBox(BuildContext context) async {
    final accountId = _mailboxDashBoardController.accountId.value;
    final session = _mailboxDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      final arguments = DestinationPickerArguments(
        accountId,
        MailboxActions.select,
        session,
        mailboxIdSelected: _destinationMailboxSelected?.id
      );

      final destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
        : await push(AppRoutes.destinationPicker, arguments: arguments);

      if (destinationMailbox is PresentationMailbox) {
        _destinationMailboxSelected = destinationMailbox;
        String? mailboxName;
        if (context.mounted) {
          mailboxName = _destinationMailboxSelected?.getDisplayName(context);
        } else {
          mailboxName = _destinationMailboxSelected?.name?.name;
        }
        mailBoxFilterInputController.text = StringConvert.writeNullToEmpty(mailboxName);
      }
    }
  }

  void applyAdvancedSearchFilter() {
    _updateFilterEmailFromAdvancedSearchView();
    if (isAdvancedSearchHasApplied) {
      searchController.activateAdvancedSearch();
    } else {
      searchController.deactivateAdvancedSearch();
    }
    if (!isAdvancedSearchHasApplied) {
      searchController.updateFilterEmail(beforeOption: const None());
    }
    searchController.isAdvancedSearchViewOpen.value = false;
    _mailboxDashBoardController.handleAdvancedSearchEmail();
  }

  Future<List<EmailAddress>> getAutoCompleteSuggestion(String word) async {
    log('AdvancedFilterController::getAutoCompleteSuggestion():  word = $word');
    _getAutoCompleteInteractor = getBinding<GetAutoCompleteInteractor>();

    return await _getAutoCompleteInteractor
      ?.execute(AutoCompletePattern(
          word: word,
          accountId: _mailboxDashBoardController.accountId.value
      )).then((value) => value.fold(
        (failure) => <EmailAddress>[],
        (success) => success is GetAutoCompleteSuccess
          ? success.listEmailAddress
          : <EmailAddress>[]
      )) ?? [];
  }

  bool get isAdvancedSearchHasApplied {
    return searchEmailFilter.from.isNotEmpty ||
        searchEmailFilter.to.isNotEmpty ||
        subjectFilterInputController.text.isNotEmpty ||
        hasKeyWordFilterInputController.text.isNotEmpty ||
        notKeyWordFilterInputController.text.isNotEmpty ||
        searchEmailFilter.emailReceiveTimeType != EmailReceiveTimeType.allTime ||
        searchEmailFilter.mailbox != PresentationMailbox.unifiedMailbox ||
        hasAttachment.isTrue;
  }

  void initSearchFilterField() {
    subjectFilterInputController.text = StringConvert.writeNullToEmpty(searchEmailFilter.subject);
    hasKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(searchEmailFilter.text?.value);
    notKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(searchEmailFilter.notKeyword.firstOrNull);
    dateFilterSelectedFormAdvancedSearch.value = searchEmailFilter.emailReceiveTimeType;
    _destinationMailboxSelected = searchEmailFilter.mailbox;
    if (currentContext != null) {
      if (searchEmailFilter.mailbox == null) {
        mailBoxFilterInputController.text = AppLocalizations.of(currentContext!).allFolders;
      } else {
        mailBoxFilterInputController.text = StringConvert.writeNullToEmpty(
          searchEmailFilter.mailbox?.getDisplayName(currentContext!)
        );
      }
    }
    hasAttachment.value = searchEmailFilter.hasAttachment;
    if (searchEmailFilter.from.isEmpty) {
      listFromEmailAddress.clear();
    } else {
      fromAddressExpandMode.value = ExpandMode.COLLAPSE;
    }
    if (searchEmailFilter.to.isEmpty) {
      listToEmailAddress.clear();
    } else {
      toAddressExpandMode.value = ExpandMode.COLLAPSE;
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
    dateFilterSelectedFormAdvancedSearch.value = receiveTime;
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
        break;
      case AdvancedSearchFilterField.to:
        listToEmailAddress = List.from(listEmailAddress);
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
      final emailAddress = EmailAddress(null, inputEmail);
      listToEmailAddress.add(emailAddress);
      keyToEmailTagEditor.currentState?.resetTextField();
      Future.delayed(const Duration(milliseconds: 300), () {
        keyToEmailTagEditor.currentState?.closeSuggestionBox();
      });
    }
  }

  void updateSortOrder(EmailSortOrderType? sortOrder) {
    if (sortOrder != null) {
      searchController.sortOrderFiltered.value = sortOrder;
    }
  }

  void _resetAllToOriginalValue() {
    _updateDateRangeTime(EmailReceiveTimeType.allTime);
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
        } else if (action is StartSearchEmailBySearchFilterAction) {
          _handleSearchEmailBySearchFilterAction(action.searchFilter);
        } else if (action is SearchEmailByFromFieldsAction) {
          searchController.clearSearchFilter();
          _resetAllToOriginalValue();
          _clearAllTextFieldInput();
          searchController.searchInputController.clear();
          searchController.deactivateAdvancedSearch();
          searchController.isAdvancedSearchViewOpen.value = false;

          listFromEmailAddress = List.from({action.emailAddress});
          final listAddress = listFromEmailAddress.map((emailAddress) => emailAddress.emailAddress).toSet();
          searchController.updateFilterEmail(fromOption: Some(listAddress));

          _mailboxDashBoardController.dispatchAction(StartSearchEmailAction());
        } else if (action is OpenAdvancedSearchViewAction) {
          initSearchFilterField();
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
  }

  void _updateFromField() {
    if (searchEmailFilter.from.isNotEmpty) {
      listFromEmailAddress = List.from(
        searchEmailFilter.from.map((address) => EmailAddress(null, address)));
    } else {
      listFromEmailAddress.clear();
    }
  }

  void _updateToField() {
    if (searchEmailFilter.to.isNotEmpty) {
      listToEmailAddress = List.from(
        searchEmailFilter.to.map((address) => EmailAddress(null, address)));
    } else {
      listToEmailAddress.clear();
    }
  }

  void onSearchAction() {
    FocusManager.instance.primaryFocus?.unfocus();
    applyAdvancedSearchFilter();
  }

  void _handleSearchEmailBySearchFilterAction(QuickSearchFilter searchFilter) {
    switch(searchFilter) {
      case QuickSearchFilter.from:
        _updateFromField();
        break;
      case QuickSearchFilter.to:
        _updateToField();
        break;
      default:
        break;
    }
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
    super.onClose();
  }
}
