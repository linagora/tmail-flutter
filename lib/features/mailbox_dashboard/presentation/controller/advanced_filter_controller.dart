import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/multiple_view_date_range_picker.dart';
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
  final listEmailAddressInit = RxList<EmailAddress>();
  final lastTextForm = ''.obs;
  final lastTextTo = ''.obs;
  TextEditingController subjectFilterInputController = TextEditingController();
  TextEditingController hasKeyWordFilterInputController =
      TextEditingController();
  TextEditingController notKeyWordFilterInputController =
      TextEditingController();
  TextEditingController dateFilterInputController = TextEditingController();
  TextEditingController mailBoxFilterInputController = TextEditingController();
  ContactSuggestionSource _contactSuggestionSource =
      ContactSuggestionSource.tMailContact;

  final SearchController searchController = Get.find<SearchController>();
  final MailboxDashBoardController _mailboxDashBoardController =
      Get.find<MailboxDashBoardController>();
  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();

  SearchEmailFilter get searchEmailFilter =>
      searchController.searchEmailFilter.value;

  final focusManager = InputFieldFocusManager.initial();

  DateTime? _startDate, _endDate;

  DateTime? get startDate => _startDate;

  DateTime? get endDate => _endDate;

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

  void selectOpenAdvanceSearch() {
    searchController.isAdvancedSearchViewOpen.toggle();
  }

  void cleanSearchFilter(BuildContext context) {
    searchController.cleanSearchFilter();
    dateFilterSelectedFormAdvancedSearch.value = EmailReceiveTimeType.allTime;
    clearDateRangeOfFilter();
    subjectFilterInputController.text = '';
    hasKeyWordFilterInputController.text = '';
    notKeyWordFilterInputController.text = '';
    dateFilterInputController.text = '';
    hasAttachment.value = false;
    searchController.isAdvancedSearchHasApply.value = false;
    searchController.isAdvancedSearchViewOpen.toggle();
    _mailboxDashBoardController.searchEmail(
        context, StringConvert.writeNullToEmpty(searchEmailFilter.text?.value));
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
      subject:
          StringConvert.writeEmptyToNull(subjectFilterInputController.text),
      emailReceiveTimeType: dateFilterSelectedFormAdvancedSearch.value,
      hasAttachment: hasAttachment.value,
      endDate: _endDate.toUTCDate(),
      startDate: _startDate.toUTCDate()
    );
  }

  void selectedMailBox() async {
    final destinationMailbox = await push(
        AppRoutes.destinationPicker,
        arguments: DestinationPickerArguments(
            _mailboxDashBoardController.accountId.value!,
            MailboxActions.select,
            mailboxIdSelected: searchController.searchEmailFilter.value.mailbox?.id));

    if (destinationMailbox is PresentationMailbox) {
      searchController.updateFilterEmail(mailbox: destinationMailbox);
      mailBoxFilterInputController.text =
          StringConvert.writeNullToEmpty(destinationMailbox.name?.name);
    }
  }

  void applyAdvancedSearchFilter(BuildContext context) {
    _updateFilterEmailFromAdvancedSearchView();
    searchController.isAdvancedSearchHasApply.value = isAdvancedSearchHasApplied;
    if (!isAdvancedSearchHasApplied) {
      final newSearchEmailFilter = searchController.searchEmailFilter.value.clearBeforeDate();
      searchController.searchEmailFilter.value = newSearchEmailFilter;
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
    searchController.updateFilterEmail(
        mailbox: PresentationMailbox.unifiedMailbox);
    subjectFilterInputController.text =
        StringConvert.writeNullToEmpty(searchEmailFilter.subject);
    hasKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(
        searchEmailFilter.text?.value);
    notKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(
        searchEmailFilter.notKeyword.firstOrNull);
    dateFilterInputController.text = StringConvert.writeNullToEmpty(
        searchEmailFilter.emailReceiveTimeType.getTitle(
            context,
            startDate: _startDate,
            endDate: _endDate));
    mailBoxFilterInputController.text =
        StringConvert.writeNullToEmpty(searchEmailFilter.mailbox?.name?.name);
    dateFilterSelectedFormAdvancedSearch.value =
        searchEmailFilter.emailReceiveTimeType;
    hasAttachment.value = searchEmailFilter.hasAttachment;
  }

  void selectDateRange(BuildContext context) {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Dialog(
              elevation: 0,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0)),
              child: MultipleViewDateRangePicker(
                confirmText: AppLocalizations.of(context).setDate,
                cancelText: AppLocalizations.of(context).cancel,
                last7daysTitle: AppLocalizations.of(context).last7Days,
                last30daysTitle: AppLocalizations.of(context).last30Days,
                last6monthsTitle: AppLocalizations.of(context).last6Months,
                lastYearTitle: AppLocalizations.of(context).lastYears,
                startDate: _startDate,
                endDate: _endDate,
                setDateActionCallback: ({startDate, endDate}) {
                  _handleSelectDateRangeResult(context, startDate, endDate);
                },
              )
          );
        }
    );
  }

  void _handleSelectDateRangeResult(
      BuildContext context,
      DateTime? startDate,
      DateTime? endDate
  ) {
    log('AdvancedFilterController::_handleSelectDateRangeResult(): startDate: $startDate');
    log('AdvancedFilterController::_handleSelectDateRangeResult(): endDate: $endDate');
    if (startDate == null) {
      _appToast.showToastWithIcon(
          context,
          textColor: Colors.black,
          message: AppLocalizations.of(context).toastMessageErrorWhenSelectStartDateIsEmpty,
          icon: _imagePaths.icNotConnection);
      return;
    }
    if (endDate == null) {
      _appToast.showToastWithIcon(
          context,
          textColor: Colors.black,
          message: AppLocalizations.of(context).toastMessageErrorWhenSelectEndDateIsEmpty,
          icon: _imagePaths.icNotConnection);
      return;
    }

    if (endDate.isBefore(startDate)) {
      _appToast.showToastWithIcon(
          context,
          textColor: Colors.black,
          message: AppLocalizations.of(context).toastMessageErrorWhenSelectDateIsInValid,
          icon: _imagePaths.icNotConnection);
      return;
    }

    _startDate = startDate;
    _endDate = endDate;
    dateFilterSelectedFormAdvancedSearch.value = EmailReceiveTimeType.customRange;
    dateFilterInputController.text = EmailReceiveTimeType.customRange.getTitle(
        context,
        startDate: startDate,
        endDate: endDate);
    dateFilterSelectedFormAdvancedSearch.refresh();

    popBack();
  }

  void clearDateRangeOfFilter() {
    _startDate = null;
    _endDate = null;

    searchController.searchEmailFilter.value =
        searchController.searchEmailFilter.value.withDateRange(
          startDate: _startDate.toUTCDate(),
          endDate: _endDate.toUTCDate());
  }

  @override
  void onClose() {
    focusManager.dispose();
    subjectFilterInputController.dispose();
    hasKeyWordFilterInputController.dispose();
    notKeyWordFilterInputController.dispose();
    mailBoxFilterInputController.dispose();
    dateFilterInputController.dispose();
    super.onClose();
  }

  @override
  void onDone() {}

  @override
  void onError(error) {}
}
