import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/input_field_focus_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AdvancedFilterController extends BaseController {
  GetAutoCompleteWithDeviceContactInteractor? _getAutoCompleteWithDeviceContactInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;

  final dateFilterSelectedFormAdvancedSearch = EmailReceiveTimeType.allTime.obs;
  final hasAttachment = false.obs;
  final lastTextForm = ''.obs;
  final lastTextTo = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  TextEditingController subjectFilterInputController = TextEditingController();
  TextEditingController hasKeyWordFilterInputController = TextEditingController();
  TextEditingController notKeyWordFilterInputController = TextEditingController();
  TextEditingController mailBoxFilterInputController = TextEditingController();
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;

  final SearchController searchController = Get.find<SearchController>();
  final MailboxDashBoardController _mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  SearchEmailFilter get searchEmailFilter =>
      searchController.searchEmailFilter.value;

  final focusManager = InputFieldFocusManager.initial();

  PresentationMailbox? _destinationMailboxSelected;

  late Worker _dashboardActionWorker;

  @override
  void onInit() {
    _registerWorkerListener();
    super.onInit();
  }

  @override
  void onReady() {
    if (!BuildUtils.isWeb) {
      Future.delayed(
          const Duration(milliseconds: 500),
          () => _checkContactPermission());
    }
    injectAutoCompleteBindings(
      _mailboxDashBoardController.sessionCurrent,
      _mailboxDashBoardController.accountId.value);
    super.onReady();
  }

  void cleanSearchFilter(BuildContext context) {
    searchController.clearSearchFilter();
    _updateDateRangeTime(EmailReceiveTimeType.allTime);
    subjectFilterInputController.text = '';
    hasKeyWordFilterInputController.text = '';
    notKeyWordFilterInputController.text = '';
    hasAttachment.value = false;
    _destinationMailboxSelected = null;
    searchController.deactivateAdvancedSearch();
    searchController.isAdvancedSearchViewOpen.toggle();
    _mailboxDashBoardController.searchEmail(context, StringConvert.writeNullToEmpty(searchEmailFilter.text?.value));
  }

  void _updateFilterEmailFromAdvancedSearchView() {
    if (hasKeyWordFilterInputController.text.isNotEmpty) {
      searchController.updateFilterEmail(text: SearchQuery(hasKeyWordFilterInputController.text));
      searchController.searchInputController.text = hasKeyWordFilterInputController.text;
    } else {
      searchController.updateFilterEmail(text: SearchQuery(searchController.searchInputController.text));
    }

    if (notKeyWordFilterInputController.text.isNotEmpty) {
      searchController.updateFilterEmail(notKeyword: notKeyWordFilterInputController.text.split(',').toSet());
    } else {
      searchController.updateFilterEmail(notKeyword: {});
    }

    if(lastTextForm.isNotEmpty && !searchController.searchEmailFilter.value.from.contains(lastTextForm.value)){
      searchController.updateFilterEmail(
        from: searchController.searchEmailFilter.value.from..add(lastTextForm.value),
      );

      lastTextForm.value = '';
    }

    if(lastTextTo.isNotEmpty &&  !searchController.searchEmailFilter.value.to.contains(lastTextTo.value)){
      searchController.updateFilterEmail(
        to: searchController.searchEmailFilter.value.to..add(lastTextTo.value),
      );

      lastTextTo.value = '';
    }

    searchController.updateFilterEmail(
      mailbox: _destinationMailboxSelected,
      subjectOption: optionOf(subjectFilterInputController.text),
      emailReceiveTimeType: dateFilterSelectedFormAdvancedSearch.value,
      hasAttachment: hasAttachment.value,
      startDateOption: optionOf(startDate.value?.toUTCDate()),
      endDateOption: optionOf(endDate.value?.toUTCDate())
    );
  }

  void selectedMailBox(BuildContext context) async {
    final accountId = _mailboxDashBoardController.accountId.value;
    final session = _mailboxDashBoardController.sessionCurrent;
    if (accountId != null) {
      final arguments = DestinationPickerArguments(
          accountId,
          MailboxActions.select,
          session,
          mailboxIdSelected: searchController.searchEmailFilter.value.mailbox?.id);

      if (BuildUtils.isWeb) {
        showDialogDestinationPicker(
            context: context,
            arguments: arguments,
            onSelectedMailbox: (destinationMailbox) {
              _destinationMailboxSelected = destinationMailbox;
              final mailboxName = destinationMailbox.name?.name;
              mailBoxFilterInputController.text = StringConvert.writeNullToEmpty(mailboxName);
            });
      } else {
        final destinationMailbox = await push(
            AppRoutes.destinationPicker,
            arguments: arguments);

        if (destinationMailbox is PresentationMailbox) {
          _destinationMailboxSelected = destinationMailbox;
          final mailboxName = destinationMailbox.name?.name;
          mailBoxFilterInputController.text = StringConvert.writeNullToEmpty(mailboxName);
        }
      }
    }
  }

  void applyAdvancedSearchFilter(BuildContext context) {
    _updateFilterEmailFromAdvancedSearchView();
    if (isAdvancedSearchHasApplied) {
      searchController.activateAdvancedSearch();
    } else {
      searchController.deactivateAdvancedSearch();
    }
    if (!isAdvancedSearchHasApplied) {
      searchController.updateFilterEmail(beforeOption: const None());
    }
    searchController.isAdvancedSearchViewOpen.toggle();
    _mailboxDashBoardController.searchEmail(
        context, StringConvert.writeNullToEmpty(searchEmailFilter.text?.value));
  }

  void _checkContactPermission() async {
    final permissionStatus = await Permission.contacts.status;
    if (permissionStatus.isGranted) {
      _contactSuggestionSource = ContactSuggestionSource.all;
    } else if (!permissionStatus.isPermanentlyDenied) {
      final requestedPermission = await Permission.contacts.request();
      _contactSuggestionSource = requestedPermission == PermissionStatus.granted
          ? ContactSuggestionSource.all
          : _contactSuggestionSource;
    }
  }

  @override
  void injectAutoCompleteBindings(Session? session, AccountId? accountId) {
    try {
      super.injectAutoCompleteBindings(session, accountId);
      _getAutoCompleteWithDeviceContactInteractor = Get.find<GetAutoCompleteWithDeviceContactInteractor>();
      _getAutoCompleteInteractor = Get.find<GetAutoCompleteInteractor>();
    } catch (e) {
      logError('AdvancedFilterController::injectAutoCompleteBindings(): $e');
    }
  }

  Future<List<EmailAddress>> getAutoCompleteSuggestion(String word) async {
    log('AdvancedFilterController::getAutoCompleteSuggestion():  $word | $_contactSuggestionSource');
    final accountId = _mailboxDashBoardController.accountId.value;

    try {
      _getAutoCompleteWithDeviceContactInteractor = Get.find<GetAutoCompleteWithDeviceContactInteractor>();
      _getAutoCompleteInteractor = Get.find<GetAutoCompleteInteractor>();
    } catch (e) {
      logError('AdvancedFilterController::getAutoCompleteSuggestion(): Exception $e');
    }

    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      if (_getAutoCompleteWithDeviceContactInteractor == null || _getAutoCompleteInteractor == null) {
        return <EmailAddress>[];
      }

      final listEmailAddress = await _getAutoCompleteWithDeviceContactInteractor!
          .execute(AutoCompletePattern(word: word, accountId: accountId))
          .then((value) => value.fold(
              (failure) => <EmailAddress>[],
              (success) => success is GetAutoCompleteSuccess
                  ? success.listEmailAddress
                  : <EmailAddress>[]));
      return listEmailAddress;
    } else {
      if (_getAutoCompleteInteractor == null) {
        return <EmailAddress>[];
      }

      final listEmailAddress = await _getAutoCompleteInteractor!
          .execute(AutoCompletePattern(word: word, accountId: accountId))
          .then((value) => value.fold(
              (failure) => <EmailAddress>[],
              (success) => success is GetAutoCompleteSuccess
                  ? success.listEmailAddress
                  : <EmailAddress>[]));
      return listEmailAddress;
    }
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

  void initSearchFilterField(BuildContext context) {
    subjectFilterInputController.text = StringConvert.writeNullToEmpty(searchEmailFilter.subject);
    hasKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(searchEmailFilter.text?.value);
    notKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(searchEmailFilter.notKeyword.firstOrNull);
    dateFilterSelectedFormAdvancedSearch.value = searchEmailFilter.emailReceiveTimeType;
    _destinationMailboxSelected = searchEmailFilter.mailbox;
    if (searchEmailFilter.mailbox == null) {
      mailBoxFilterInputController.text = AppLocalizations.of(context).allMailboxes;
    } else {
      mailBoxFilterInputController.text = StringConvert.writeNullToEmpty(searchEmailFilter.mailbox?.name?.name);
    }
    hasAttachment.value = searchEmailFilter.hasAttachment;
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

  void _resetAllToOriginalValue() {
    dateFilterSelectedFormAdvancedSearch.value = EmailReceiveTimeType.allTime;
    hasAttachment.value = false;
    lastTextForm.value = '';
    lastTextTo.value = '';
    startDate.value = null;
    endDate.value = null;
  }

  void _clearAllTextFieldInput() {
    subjectFilterInputController.clear();
    hasKeyWordFilterInputController.clear();
    notKeyWordFilterInputController.clear();
    mailBoxFilterInputController.clear();
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
        }
      }
    );
  }

  void _unregisterWorkerListener() {
    _dashboardActionWorker.dispose();
  }

  void _handleClearAllFieldOfAdvancedSearch() {
    _resetAllToOriginalValue();
    _clearAllTextFieldInput();
  }

  @override
  void onClose() {
    focusManager.dispose();
    subjectFilterInputController.dispose();
    hasKeyWordFilterInputController.dispose();
    notKeyWordFilterInputController.dispose();
    mailBoxFilterInputController.dispose();
    _unregisterWorkerListener();
    super.onClose();
  }

  @override
  void onDone() {}
}
