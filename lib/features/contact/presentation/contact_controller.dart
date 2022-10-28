
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/contact/presentation/model/contact_arguments.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnSelectedContactCallback = Function(EmailAddress emailAddress);

class ContactController extends BaseController {

  TextEditingController? textInputSearchController;
  FocusNode? textInputSearchFocus;
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;

  final searchQuery = SearchQuery.initial().obs;
  final listContactSearched = RxList<EmailAddress>();

  GetAutoCompleteWithDeviceContactInteractor? _getAutoCompleteWithDeviceContactInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;

  late Debouncer<String> _deBouncerTime;
  late AccountId _accountId;
  late Session _session;

  ContactArguments? arguments;
  EmailAddress? contactSelected;
  OnSelectedContactCallback? onSelectedContactCallback;
  VoidCallback? onDismissContactView;

  @override
  void onInit() {
    super.onInit();
    textInputSearchController = TextEditingController();
    textInputSearchFocus = FocusNode();
    _initializeDebounceTimeTextSearchChange();
  }

  @override
  void onReady() async {
    textInputSearchFocus?.requestFocus();
    if (arguments != null) {
      _accountId = arguments!.accountId;
      _session = arguments!.session;
      final listContactSelected = arguments!.listContactSelected;
      log('ContactController::onReady(): arguments: $arguments');
      log('ContactController::onReady(): listContactSelected: $listContactSelected');
      if (listContactSelected.isNotEmpty) {
        contactSelected = EmailAddress(listContactSelected.first, listContactSelected.first);
      }
      injectAutoCompleteBindings(_session, _accountId);
    }
    if (!BuildUtils.isWeb) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _checkContactPermission());
    }
    super.onReady();
  }

  @override
  void onClose() {
    _disposeWidget();
    super.onClose();
  }

  void _initializeDebounceTimeTextSearchChange() {
    _deBouncerTime = Debouncer<String>(
        const Duration(milliseconds: 500),
        initialValue: '');
    _deBouncerTime.values.listen((value) async {
      searchQuery.value = SearchQuery(value);
      _searchContactByNameOrEmail(searchQuery.value.value);
    });
  }

  void onTextSearchChange(String text) {
    _deBouncerTime.value = text;
  }

  void clearAllTextInputSearchForm() {
    textInputSearchController?.clear();
    searchQuery.value = SearchQuery.initial();
    textInputSearchFocus?.requestFocus();
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

  void _searchContactByNameOrEmail(String query) async {
    log('ContactController::_searchContactByNameOrEmail(): query: $query');
    final listContact = await _getAutoCompleteSuggestion(query);
    listContactSearched.value = listContact;
  }

  @override
  void injectAutoCompleteBindings(Session? session, AccountId? accountId) {
    try {
      super.injectAutoCompleteBindings(session, accountId);
      _getAutoCompleteWithDeviceContactInteractor = Get.find<GetAutoCompleteWithDeviceContactInteractor>();
      _getAutoCompleteInteractor = Get.find<GetAutoCompleteInteractor>();
    } catch (e) {
      logError('ContactController::injectAutoCompleteBindings(): $e');
    }
  }

  Future<List<EmailAddress>> _getAutoCompleteSuggestion(String query) async {
    try {
      _getAutoCompleteWithDeviceContactInteractor = Get.find<GetAutoCompleteWithDeviceContactInteractor>();
      _getAutoCompleteInteractor = Get.find<GetAutoCompleteInteractor>();
    } catch (e) {
      logError('ContactController::getAutoCompleteSuggestion(): Exception $e');
    }

    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      if (_getAutoCompleteWithDeviceContactInteractor == null || _getAutoCompleteInteractor == null) {
        return <EmailAddress>[];
      }

      final listEmailAddress = await _getAutoCompleteWithDeviceContactInteractor!
          .execute(AutoCompletePattern(word: query, limit: 30, accountId: _accountId))
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
          .execute(AutoCompletePattern(word: query, limit: 30, accountId: _accountId))
          .then((value) => value.fold(
              (failure) => <EmailAddress>[],
              (success) => success is GetAutoCompleteSuccess
                  ? success.listEmailAddress
                  : <EmailAddress>[]));
      return listEmailAddress;
    }
  }

  void _disposeWidget() {
    textInputSearchFocus?.dispose();
    textInputSearchFocus = null;
    textInputSearchController?.dispose();
    textInputSearchController = null;
    _deBouncerTime.cancel();
  }

  void selectContact(BuildContext context, EmailAddress emailAddress) {
    FocusScope.of(context).unfocus();

    if (BuildUtils.isWeb) {
      _disposeWidget();
      onSelectedContactCallback?.call(emailAddress);
    } else {
      popBack(result: emailAddress);
    }
  }

  void closeContactView(BuildContext context) {
    clearAllTextInputSearchForm();
    FocusScope.of(context).unfocus();

    if (BuildUtils.isWeb) {
      _disposeWidget();
      onDismissContactView?.call();
    } else {
      popBack();
    }
  }

  @override
  void onDone() {}
}