
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_device_contact_suggestions_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_all_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';
import 'package:tmail_ui_user/features/contact/presentation/model/contact_arguments.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_suggestion_box_item.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ContactController extends BaseController {

  final TextEditingController textInputSearchController = TextEditingController();
  final FocusNode textInputSearchFocus = FocusNode();
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;

  final searchQuery = SearchQuery.initial().obs;
  final session = Rxn<Session>();
  final listContactSearched = RxList<EmailAddress>();
  final contactArguments = Rxn<ContactArguments>();

  GetAllAutoCompleteInteractor? _getAllAutoCompleteInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;
  GetDeviceContactSuggestionsInteractor? _getDeviceContactSuggestionsInteractor;

  final Debouncer<String> _deBouncerTime = Debouncer<String>(const Duration(milliseconds: 300), initialValue: '');
  AccountId? _accountId;

  EmailAddress? contactSelected;
  SelectedContactCallbackAction? onSelectedContactCallback;
  VoidCallback? onDismissContactView;

  @override
  void onInit() {
    super.onInit();
    ThemeUtils.setStatusBarTransparentColor();
    log('ContactController::onInit():arguments: ${Get.arguments}');
    contactArguments.value = Get.arguments;
    _deBouncerTime.values.listen((value) {
      searchQuery.value = SearchQuery(value);
      _searchContactByNameOrEmail(searchQuery.value.value);
    });
  }

  @override
  void onReady() {
    super.onReady();
    textInputSearchFocus.requestFocus();
    if (contactArguments.value != null) {
      _accountId = contactArguments.value!.accountId;
      session.value = contactArguments.value!.session;
      final listContactSelected = contactArguments.value!.listContactSelected;
      log('ContactController::onReady(): listContactSelected: $listContactSelected');
      if (listContactSelected.isNotEmpty) {
        contactSelected = EmailAddress(listContactSelected.first, listContactSelected.first);
      }
      injectAutoCompleteBindings(session.value, _accountId);
    }
    if (PlatformInfo.isMobile) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _checkContactPermission());
    }
  }

  @override
  void onClose() {
    log('ContactController::onClose():');
    textInputSearchFocus.dispose();
    textInputSearchController.dispose();
    _deBouncerTime.cancel();
    super.onClose();
  }

  void onTextSearchChange(String text) {
    _deBouncerTime.value = text;
  }

  void onSearchTextAction(String text) {
    _deBouncerTime.value = text;
  }

  void clearAllTextInputSearchForm() {
    textInputSearchController.clear();
    searchQuery.value = SearchQuery.initial();
    textInputSearchFocus.requestFocus();
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

  Future<List<EmailAddress>> _getAutoCompleteSuggestion(String query) async {
    _getAllAutoCompleteInteractor = getBinding<GetAllAutoCompleteInteractor>();
    _getAutoCompleteInteractor = getBinding<GetAutoCompleteInteractor>();
    _getDeviceContactSuggestionsInteractor = getBinding<GetDeviceContactSuggestionsInteractor>();

    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      if (_getAllAutoCompleteInteractor != null) {
        return await _getAllAutoCompleteInteractor!
          .execute(AutoCompletePattern(word: query, limit: 30, accountId: _accountId))
          .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => success is GetAutoCompleteSuccess
              ? success.listEmailAddress
              : <EmailAddress>[]
          ));
      } else if (_getDeviceContactSuggestionsInteractor != null) {
        return await _getDeviceContactSuggestionsInteractor!
          .execute(AutoCompletePattern(word: query, limit: 30, accountId: _accountId))
          .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => success is GetDeviceContactSuggestionsSuccess
              ? success.listEmailAddress
              : <EmailAddress>[]
          ));
      } else {
        return <EmailAddress>[];
      }
    } else {
      if (_getAutoCompleteInteractor == null) {
        return <EmailAddress>[];
      } else {
        return await _getAutoCompleteInteractor!
          .execute(AutoCompletePattern(word: query, limit: 30, accountId: _accountId))
          .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => success is GetAutoCompleteSuccess
              ? success.listEmailAddress
              : <EmailAddress>[]
          ));
      }
    }
  }

  void selectContact(BuildContext context, EmailAddress emailAddress) {
    KeyboardUtils.hideKeyboard(context);
    popBack(result: emailAddress);
  }

  void closeContactView() {
    textInputSearchController.clear();
    searchQuery.value = SearchQuery.initial();
    textInputSearchFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    popBack();
  }
}