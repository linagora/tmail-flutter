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
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef _AddressFocusConfig = ({
  FocusNode focusNode,
  Rx<ExpandMode> expandMode,
  Rx<ExpandMode> otherExpandMode,
  void Function() autoCreateTag,
});

typedef _AddressTagConfig = ({
  TextEditingController textController,
  Set<String> Function(SearchEmailFilter filter) committedAddresses,
  void Function(SearchFilterEmailAddress address) addAddress,
  GlobalKey<TagsEditorState> keyTagEditor,
});

class AdvancedFilterController extends BaseController {
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;

  final GlobalKey<TagsEditorState> keyFromEmailTagEditor = GlobalKey<TagsEditorState>();
  final GlobalKey<TagsEditorState> keyToEmailTagEditor = GlobalKey<TagsEditorState>();
  final fromAddressExpandMode = ExpandMode.EXPAND.obs;
  final toAddressExpandMode = ExpandMode.EXPAND.obs;

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

  /// Committed SSOT mutations flow through [SearchFilterMutation] — `update`, the
  /// address/keyword helpers, `set`, `clear` — so no call site owns the set-rebuild
  /// or copyWith plumbing. See ADR-0093.
  SearchFilterNotifier get _filterNotifier =>
      appProviderContainer.read(searchFilterProvider.notifier);

  List<EmailAddress> get listFromEmailAddress =>
      _toEmailAddresses(_committedFilter.from);

  List<EmailAddress> get listToEmailAddress =>
      _toEmailAddresses(_committedFilter.to);

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
    // Sync only the sort field so any filters already committed by other search
    // surfaces are preserved.
    _filterNotifier.setSortOrder(emailSortOrderType);
  }

  void _updateSortOrder(EmailSortOrderType emailSortOrderType) {
    _filterNotifier.setSortOrder(emailSortOrderType);
  }

  void clearSearchFilter() {
    // Route through SearchController so the obs mirror's stale cursors are dropped
    // too; a bare notifier.clear() only resets the committed SSOT. See ADR-0093.
    searchController.clearSearchFilter();
    _clearAllTextFieldInput();
    _mailboxDashBoardController.handleClearAdvancedSearchFilterEmail();
  }

  MailboxDashBoardController get mailboxDashBoardController => _mailboxDashBoardController;

  void selectedMailBox(
    BuildContext context, {
    PresentationMailbox? mailboxSelected,
    required SearchFilterNotifier filterNotifier,
  }) async {
    final accountId = _mailboxDashBoardController.accountId.value;
    final session = _mailboxDashBoardController.sessionCurrent;

    if (session == null || accountId == null) return;

    final arguments = DestinationPickerArguments(
      accountId,
      MailboxActions.select,
      session,
      mailboxIdSelected: mailboxSelected?.id
    );

    final destinationMailbox = PlatformInfo.isWeb
      ? await DialogRouter().pushGeneralDialog(
          routeName: AppRoutes.destinationPicker,
          arguments: arguments)
      : await push(AppRoutes.destinationPicker, arguments: arguments);

    if (destinationMailbox is! PresentationMailbox) return;

    filterNotifier.setMailbox(destinationMailbox);
  }

  void applyAdvancedSearchFilter({
    required SearchEmailFilter committedFilter,
    required SearchFilterNotifier filterNotifier,
  }) {
    // Strip any pagination cursor before running a fresh search.
    filterNotifier.set(committedFilter);
    if (committedFilter.isApplied) {
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

  void initSearchFilterField() {
    subjectFilterInputController.text = StringConvert.writeNullToEmpty(
      _committedFilter.subject);

    hasKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(
      _committedFilter.text?.value);

    notKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(
      _committedFilter.notKeyword.join(','));

    if (_committedFilter.from.isEmpty) {
      fromAddressExpandMode.value = ExpandMode.EXPAND;
    } else {
      fromAddressExpandMode.value = ExpandMode.COLLAPSE;
    }

    if (_committedFilter.to.isEmpty) {
      toAddressExpandMode.value = ExpandMode.EXPAND;
    } else {
      toAddressExpandMode.value = ExpandMode.COLLAPSE;
    }
  }

  void selectDateRange(
    BuildContext context, {
    required SearchEmailFilter committedFilter,
    required SearchFilterNotifier filterNotifier,
  }) {
    searchController.showMultipleViewDateRangePicker(
      context,
      committedFilter.startDate?.value.toLocal(),
      committedFilter.endDate?.value.toLocal(),
      onCallbackAction: (startDate, endDate) =>
        _updateDateRangeTime(
          EmailReceiveTimeType.customRange,
          newStartDate: startDate,
          newEndDate: endDate,
          filterNotifier: filterNotifier
        )
    );
  }

  void _updateDateRangeTime(
    EmailReceiveTimeType receiveTime, {
    DateTime? newStartDate,
    DateTime? newEndDate,
    SearchFilterNotifier? filterNotifier,
  }) {
    final notifier = filterNotifier ?? _filterNotifier;
    if (receiveTime == EmailReceiveTimeType.customRange) {
      notifier.update(SearchFilterPatch()
        ..emailReceiveTimeTypeOption = Some(receiveTime)
        ..startDateOption = optionOf(newStartDate?.toUTCDate())
        ..endDateOption = optionOf(newEndDate?.toUTCDate()));
    } else {
      final dateRange = receiveTime.toDateRange();
      notifier.update(SearchFilterPatch()
        ..emailReceiveTimeTypeOption = Some(receiveTime)
        ..startDateOption = optionOf(dateRange.start)
        ..endDateOption = optionOf(dateRange.end));
    }
  }

  void updateReceiveDateSearchFilter(
    BuildContext context,
    EmailReceiveTimeType receiveTime, {
    required SearchEmailFilter committedFilter,
    required SearchFilterNotifier filterNotifier,
  }) {
    if (receiveTime == EmailReceiveTimeType.customRange) {
      searchController.showMultipleViewDateRangePicker(
        context,
        committedFilter.startDate?.value.toLocal(),
        committedFilter.endDate?.value.toLocal(),
        onCallbackAction: (startDate, endDate) =>
          _updateDateRangeTime(
            EmailReceiveTimeType.customRange,
            newStartDate: startDate,
            newEndDate: endDate,
            filterNotifier: filterNotifier
          )
      );
    } else {
      _updateDateRangeTime(receiveTime, filterNotifier: filterNotifier);
    }
  }

  void _onFromFieldFocusChange() =>
      _onAddressFieldFocusChange(FilterField.from);

  void _onToFieldFocusChange() =>
      _onAddressFieldFocusChange(FilterField.to);

  void _onAddressFieldFocusChange(FilterField field) {
    final config = _addressFocusConfig(field);
    if (config.focusNode.hasFocus) {
      config.expandMode.value = ExpandMode.EXPAND;
      config.otherExpandMode.value = ExpandMode.COLLAPSE;
      _closeSuggestionBox();
    } else {
      config.expandMode.value = ExpandMode.COLLAPSE;
      config.autoCreateTag();
    }
  }

  _AddressFocusConfig _addressFocusConfig(FilterField field) {
    switch (field) {
      case FilterField.from:
        return (
          focusNode: focusManager.fromFieldFocusNode,
          expandMode: fromAddressExpandMode,
          otherExpandMode: toAddressExpandMode,
          autoCreateTag: _autoCreateTagFromField,
        );
      case FilterField.to:
        return (
          focusNode: focusManager.toFieldFocusNode,
          expandMode: toAddressExpandMode,
          otherExpandMode: fromAddressExpandMode,
          autoCreateTag: _autoCreateTagToField,
        );
      default:
        throw ArgumentError.value(field);
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
    SearchFilterNotifier filterNotifier
  ) {
    switch(field) {
      case FilterField.from:
        filterNotifier.setSenders(
          listEmailAddress.asSetAddress().asSearchFilterEmailSet());
        break;
      case FilterField.to:
        filterNotifier.setRecipients(
          listEmailAddress.asSetAddress().asSearchFilterEmailSet());
        break;
      default:
        break;
    }
  }

  void _autoCreateTagFromField() =>
      _autoCreateTagForField(FilterField.from);

  void _autoCreateTagToField() =>
      _autoCreateTagForField(FilterField.to);

  void _autoCreateTagForField(FilterField field) {
    final config = _addressTagConfig(field);
    final inputEmail = config.textController.text;
    if (inputEmail.isEmpty ||
        config.committedAddresses(_committedFilter).contains(inputEmail)) {
      return;
    }

    config.addAddress(inputEmail.asSearchFilterEmailAddress());
    config.keyTagEditor.currentState?.resetTextField();
    Future.delayed(const Duration(milliseconds: 300), () {
      config.keyTagEditor.currentState?.closeSuggestionBox();
    });
  }

  _AddressTagConfig _addressTagConfig(FilterField field) {
    switch (field) {
      case FilterField.from:
        return (
          textController: fromEmailAddressController,
          committedAddresses: (filter) => filter.from,
          addAddress: _filterNotifier.addSender,
          keyTagEditor: keyFromEmailTagEditor,
        );
      case FilterField.to:
        return (
          textController: toEmailAddressController,
          committedAddresses: (filter) => filter.to,
          addAddress: _filterNotifier.addRecipient,
          keyTagEditor: keyToEmailTagEditor,
        );
      default:
        throw ArgumentError.value(field);
    }
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
          initSearchFilterField();
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
    _clearAllTextFieldInput();
    // Cursor-safe clear: also drop stale cursors on the obs mirror. See ADR-0093.
    searchController.clearSearchFilter();
  }

  void onSearchAction({
    required SearchEmailFilter committedFilter,
    required SearchFilterNotifier filterNotifier,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    applyAdvancedSearchFilter(
      committedFilter: committedFilter,
      filterNotifier: filterNotifier);
  }

  void _handleStartSearchEmailAction() {
    initSearchFilterField();
  }

  void onTextChanged(
    FilterField filterField,
    String value,
    SearchFilterNotifier filterNotifier,
  ) {
    switch (filterField) {
      case FilterField.subject:
        filterNotifier.setSubject(value.asSearchFilterTextInput());
        break;
      case FilterField.hasKeyword:
        filterNotifier.setText(value.asSearchFilterTextInput());
        break;
      case FilterField.notKeyword:
        filterNotifier.setNotKeywords(value.asSearchFilterTextInput());
        break;
      default:
        break;
    }
  }

  void removeDraggableEmailAddress(
    DraggableEmailAddress draggableEmailAddress,
    SearchFilterNotifier filterNotifier,
  ) {
    log('AdvancedFilterController::removeDraggableEmailAddress:removeDraggableEmailAddress: $draggableEmailAddress');
    switch(draggableEmailAddress.filterField) {
      case FilterField.to:
        filterNotifier.removeRecipient(
          draggableEmailAddress.emailAddress.emailAddress
              .asSearchFilterEmailAddress());
        toAddressExpandMode.value = ExpandMode.EXPAND;
        toAddressExpandMode.refresh();
        break;
      case FilterField.from:
        filterNotifier.removeSender(
          draggableEmailAddress.emailAddress.emailAddress
              .asSearchFilterEmailAddress());
        fromAddressExpandMode.value = ExpandMode.EXPAND;
        fromAddressExpandMode.refresh();
        break;
      default:
        break;
    }
  }

  void _handleQuickSearchEmailByFromAction(EmailAddress emailAddress) {
    searchController.clearSearchFilter(sortOrderType: _committedFilter.sortOrderType);
    _clearAllTextFieldInput();
    searchController.searchInputController.clear();
    searchController.deactivateAdvancedSearch();
    searchController.isAdvancedSearchViewOpen.value = false;
    _filterNotifier.addSender(emailAddress.emailAddress.asSearchFilterEmailAddress());
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
    super.onClose();
  }

  List<EmailAddress> _toEmailAddresses(Set<String> emails) =>
      emails.map((email) => EmailAddress(null, email)).toList();
}
