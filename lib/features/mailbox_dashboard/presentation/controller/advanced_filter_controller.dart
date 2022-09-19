import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AdvancedFilterController extends GetxController {
  late GetAutoCompleteWithDeviceContactInteractor _getAutoCompleteWithDeviceContactInteractor;
  late GetAutoCompleteInteractor _getAutoCompleteInteractor;

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

  SearchEmailFilter get searchEmailFilter =>
      searchController.searchEmailFilter.value;

  final focusManager = InputFieldFocusManager.initial();

  @override
  void onReady() async {
    if (!BuildUtils.isWeb) {
      Future.delayed(
          const Duration(milliseconds: 500), () => _checkContactPermission());
    }
    super.onReady();
  }

  void selectOpenAdvanceSearch() {
    searchController.isAdvancedSearchViewOpen.toggle();
  }

  void cleanSearchFilter(BuildContext context) {
    searchController.cleanSearchFilter();
    dateFilterSelectedFormAdvancedSearch.value = EmailReceiveTimeType.allTime;
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
    );
  }

  void selectedMailBox() async {
    final destinationMailbox = await push(
        AppRoutes.DESTINATION_PICKER,
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
    searchController.isAdvancedSearchHasApply.value = _checkAdvancedSearchHasApply();
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

  Future<List<EmailAddress>> getAutoCompleteSuggestion(
      {required String word}) async {

    if (!Get.isRegistered<GetAutoCompleteWithDeviceContactInteractor>() ||
      !Get.isRegistered<GetAutoCompleteInteractor>()) {
      _mailboxDashBoardController.injectAutoCompleteBindings();
    }

    _getAutoCompleteWithDeviceContactInteractor = Get.find<GetAutoCompleteWithDeviceContactInteractor>();
    _getAutoCompleteInteractor = Get.find<GetAutoCompleteInteractor>();

    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      return await _getAutoCompleteWithDeviceContactInteractor
          .execute(AutoCompletePattern(
              word: word,
              accountId: _mailboxDashBoardController.accountId.value))
          .then((value) => value.fold(
              (failure) => <EmailAddress>[],
              (success) => success is GetAutoCompleteSuccess
                  ? success.listEmailAddress
                  : <EmailAddress>[]));
    }
    return await _getAutoCompleteInteractor
        .execute(AutoCompletePattern(
            word: word, accountId: _mailboxDashBoardController.accountId.value))
        .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => success is GetAutoCompleteSuccess
                ? success.listEmailAddress
                : <EmailAddress>[]));
  }

  bool _checkAdvancedSearchHasApply() {
    return searchEmailFilter.from.isNotEmpty ||
        searchEmailFilter.to.isNotEmpty ||
        subjectFilterInputController.text.isNotEmpty ||
        hasKeyWordFilterInputController.text.isNotEmpty ||
        notKeyWordFilterInputController.text.isNotEmpty ||
        searchEmailFilter.emailReceiveTimeType != EmailReceiveTimeType.allTime ||
        searchEmailFilter.mailbox != _mailboxDashBoardController.selectedMailbox.value ||
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
        searchEmailFilter.emailReceiveTimeType.getTitle(context));
    mailBoxFilterInputController.text =
        StringConvert.writeNullToEmpty(searchEmailFilter.mailbox?.name?.name);
    dateFilterSelectedFormAdvancedSearch.value =
        searchEmailFilter.emailReceiveTimeType;
    hasAttachment.value = searchEmailFilter.hasAttachment;
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
}
