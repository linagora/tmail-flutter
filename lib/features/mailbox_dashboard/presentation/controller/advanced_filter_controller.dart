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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/advanced_filter_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AdvancedFilterController extends GetxController {
  late GetAutoCompleteWithDeviceContactInteractor
      _getAutoCompleteWithDeviceContactInteractor;
  late GetAutoCompleteInteractor _getAutoCompleteInteractor;

  final dateFilterSelectedFormAdvancedSearch = EmailReceiveTimeType.allTime.obs;
  final hasAttachment = false.obs;
  final listEmailAddressInit = RxList<EmailAddress>();
  final listTagFromSelected = RxList<String>();
  final listTagToSelected = RxList<String>();

  TextEditingController subjectFilterInputController = TextEditingController();
  TextEditingController hasKeyWordFilterInputController =
      TextEditingController();
  TextEditingController notKeyWordFilterInputController =
      TextEditingController();
  TextEditingController dateFilterInputController = TextEditingController();
  TextEditingController mailBoxFilterInputController = TextEditingController();
  ContactSuggestionSource _contactSuggestionSource =
      ContactSuggestionSource.tMailContact;

  final SearchController _searchController = Get.find<SearchController>();
  final MailboxDashBoardController _mailboxDashBoardController =
      Get.find<MailboxDashBoardController>();

  AdvancedFilterController() {
    AdvancedFilterBindings().dependencies();
    _getAutoCompleteWithDeviceContactInteractor =
        Get.find<GetAutoCompleteWithDeviceContactInteractor>();
    _getAutoCompleteInteractor = Get.find<GetAutoCompleteInteractor>();
  }

  SearchEmailFilter get searchEmailFilter =>
      _searchController.searchEmailFilter.value;

  @override
  void onReady() async {
    if (!BuildUtils.isWeb) {
      Future.delayed(
          const Duration(milliseconds: 500), () => _checkContactPermission());
    }
    super.onReady();
  }

  void selectOpenAdvanceSearch() {
    _searchController.isAdvancedSearchViewOpen.toggle();
  }

  void cleanSearchFilter(BuildContext context) {
    _searchController.cleanSearchFilter();
    dateFilterSelectedFormAdvancedSearch.value = EmailReceiveTimeType.allTime;
    listTagFromSelected.clear();
    listTagToSelected.clear();
    subjectFilterInputController.text = '';
    hasKeyWordFilterInputController.text = '';
    notKeyWordFilterInputController.text = '';
    dateFilterInputController.text = '';
    hasAttachment.value = false;
    _searchController.isAdvancedSearchHasApply.value = false;
    _searchController.isAdvancedSearchViewOpen.toggle();
    _mailboxDashBoardController.searchEmail(
        context, StringConvert.writeNullToEmpty(searchEmailFilter.text?.value));
  }

  void _updateFilterEmailFromAdvancedSearchView() {
    if (listTagFromSelected.isNotEmpty) {
      _searchController.updateFilterEmail(
          from: listTagFromSelected.toSet());
    } else {
      _searchController.updateFilterEmail(from: {});
    }
    if (listTagToSelected.isNotEmpty) {
      _searchController.updateFilterEmail(
          to: listTagToSelected.toSet());
    } else {
      _searchController.updateFilterEmail(to: {});
    }
    if (hasKeyWordFilterInputController.text.isNotEmpty) {
      _searchController.updateFilterEmail(
          hasKeyword: hasKeyWordFilterInputController.text.split(',').toSet());
    } else {
      _searchController.updateFilterEmail(hasKeyword: {});
    }
    if (notKeyWordFilterInputController.text.isNotEmpty) {
      _searchController.updateFilterEmail(
          notKeyword: notKeyWordFilterInputController.text.split(',').toSet());
    } else {
      _searchController.updateFilterEmail(notKeyword: {});
    }

    _searchController.updateFilterEmail(
      subject:
          StringConvert.writeEmptyToNull(subjectFilterInputController.text),
      emailReceiveTimeType: dateFilterSelectedFormAdvancedSearch.value,
      hasAttachment: hasAttachment.value,
    );
  }

  Future<void> selectedMailBox() async {
    final PresentationMailbox destinationMailbox = await push(
        AppRoutes.DESTINATION_PICKER,
        arguments: DestinationPickerArguments(
            _mailboxDashBoardController.accountId.value!,
            MailboxActions.moveEmail));
    _searchController.updateFilterEmail(mailbox: destinationMailbox);
    mailBoxFilterInputController.text =
        StringConvert.writeNullToEmpty(destinationMailbox.name?.name);
  }

  void applyAdvancedSearchFilter(BuildContext context) {
    _updateFilterEmailFromAdvancedSearchView();
    _mailboxDashBoardController.searchEmail(
        context, StringConvert.writeNullToEmpty(searchEmailFilter.text?.value));
    _searchController.isAdvancedSearchViewOpen.toggle();
    _searchController.isAdvancedSearchHasApply.value =
        _checkAdvancedSearchHasApply();
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
    return listTagFromSelected.isNotEmpty ||
        listTagToSelected.isNotEmpty ||
        subjectFilterInputController.text.isNotEmpty ||
        hasKeyWordFilterInputController.text.isNotEmpty ||
        notKeyWordFilterInputController.text.isNotEmpty ||
        dateFilterInputController.text.isNotEmpty ||
        mailBoxFilterInputController.text.isNotEmpty ||
        hasAttachment.isTrue;
  }

  void initSearchFilterField(BuildContext context) {
    _searchController.updateFilterEmail(
        mailbox: _mailboxDashBoardController.selectedMailbox.value);
    subjectFilterInputController.text =
        StringConvert.writeNullToEmpty(searchEmailFilter.subject);
    hasKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(
        searchEmailFilter.hasKeyword.firstOrNull);
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
    subjectFilterInputController.dispose();
    hasKeyWordFilterInputController.dispose();
    notKeyWordFilterInputController.dispose();
    mailBoxFilterInputController.dispose();
    dateFilterInputController.dispose();
    super.onClose();
  }
}
