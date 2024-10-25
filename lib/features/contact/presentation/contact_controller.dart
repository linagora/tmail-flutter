
import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/auto_complete_result_mixin.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_all_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';
import 'package:tmail_ui_user/features/contact/presentation/model/contact_arguments.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_suggestion_box_item.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class ContactController extends BaseController with AutoCompleteResultMixin {

  final TextEditingController textInputSearchController = TextEditingController();
  final FocusNode textInputSearchFocus = FocusNode();
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;

  final searchQuery = SearchQuery.initial().obs;
  final searchedContactList = RxList<EmailAddress>();
  final selectedContactList = RxList<EmailAddress>();
  final contactArguments = Rxn<ContactArguments>();
  final searchStatus = SearchStatus.INACTIVE.obs;
  final searchViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));

  GetAllAutoCompleteInteractor? _getAllAutoCompleteInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;
  GetDeviceContactSuggestionsInteractor? _getDeviceContactSuggestionsInteractor;

  final Debouncer<String> _deBouncerTime = Debouncer<String>(
    const Duration(milliseconds: 300),
    initialValue: ''
  );
  AccountId? _accountId;
  SelectedContactCallbackAction? onSelectedContactCallback;
  VoidCallback? onDismissContactView;
  StreamSubscription<String>? _deBouncerTimeStreamSubscription;

  late int _minInputLengthAutocomplete;

  @override
  void onInit() {
    super.onInit();
    ThemeUtils.setStatusBarTransparentColor();
    log('ContactController::onInit():arguments: ${Get.arguments}');
    contactArguments.value = Get.arguments;
    _deBouncerTimeStreamSubscription = _deBouncerTime.values.listen(_handleDeBounceTimeSearchContact);
    textInputSearchFocus.addListener(_onSearchInputTextFocusListener);
  }

  @override
  void onReady() {
    super.onReady();
    if (contactArguments.value != null) {
      _accountId = contactArguments.value!.accountId;
      selectedContactList.value = contactArguments.value!.selectedContactList
        .map((mailAddress) => EmailAddress(null, mailAddress))
        .toList();
      injectAutoCompleteBindings(contactArguments.value!.session, _accountId);

      if (selectedContactList.isEmpty) {
        textInputSearchFocus.requestFocus();
      }
    }
    _minInputLengthAutocomplete = _fetchMinInputLengthAutocomplete();
    if (PlatformInfo.isMobile) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _checkContactPermission());
    }
  }

  @override
  void onClose() {
    log('ContactController::onClose():');
    searchViewState.value = Right(UIState.idle);
    textInputSearchFocus.removeListener(_onSearchInputTextFocusListener);
    textInputSearchFocus.dispose();
    textInputSearchController.dispose();
    _deBouncerTimeStreamSubscription?.cancel();
    _deBouncerTime.cancel();
    _accountId = null;
    super.onClose();
  }

  void _onSearchInputTextFocusListener() {
    if (textInputSearchFocus.hasFocus && textInputSearchController.text.trim().isEmpty) {
      searchStatus.value = SearchStatus.INACTIVE;
    }
  }

  void onTextSearchChange(String text) {
    _deBouncerTime.value = text;
  }

  void onSearchTextAction(String text) {
    _deBouncerTime.value = text;
  }

  Future<void> _handleDeBounceTimeSearchContact(String value) async {
    final queryStringTrimmed = value.trim();

    if (queryStringTrimmed.length < _minInputLengthAutocomplete) {
      searchStatus.value = SearchStatus.INACTIVE;
      return;
    }

    searchStatus.value = SearchStatus.ACTIVE;
    searchViewState.value = Right(SearchingState());
    searchQuery.value = SearchQuery(queryStringTrimmed);
    await _searchContactByNameOrEmail(searchQuery.value.value);
    searchViewState.value = Right(UIState.idle);
  }

  void clearAllTextInputSearchForm() {
    textInputSearchController.clear();
    searchQuery.value = SearchQuery.initial();
    searchedContactList.clear();
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

  Future<void> _searchContactByNameOrEmail(String query) async {
    log('ContactController::_searchContactByNameOrEmail(): query: $query');
    final listContact = await _getAutoCompleteSuggestion(query);
    searchedContactList.value = listContact;
  }

  Future<List<EmailAddress>> _getAutoCompleteSuggestion(String queryString) async {
    _getAllAutoCompleteInteractor = getBinding<GetAllAutoCompleteInteractor>();
    _getAutoCompleteInteractor = getBinding<GetAutoCompleteInteractor>();
    _getDeviceContactSuggestionsInteractor = getBinding<GetDeviceContactSuggestionsInteractor>();

    final autoCompletePattern = AutoCompletePattern(
      word: queryString,
      limit: 30,
      accountId: _accountId);

    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      if (_getAllAutoCompleteInteractor != null) {
        return await _getAllAutoCompleteInteractor!
          .execute(autoCompletePattern)
          .then((value) => handleAutoCompleteResultState(
            resultState: value,
            queryString: queryString,
          )
        );
      } else if (_getDeviceContactSuggestionsInteractor != null) {
        return await _getDeviceContactSuggestionsInteractor!
          .execute(autoCompletePattern)
          .then((value) => handleAutoCompleteResultState(
            resultState: value,
            queryString: queryString,
          )
        );
      } else {
        return <EmailAddress>[];
      }
    } else {
      return await _getAutoCompleteInteractor
        ?.execute(autoCompletePattern)
        .then((value) => handleAutoCompleteResultState(
          resultState: value,
          queryString: queryString,
        )
      ) ?? <EmailAddress>[];
    }
  }

  void handleOnSelectContactAction(EmailAddress emailAddress) {
    log('ContactController::selectContact:emailAddress = $emailAddress');
    final isEmailAddressExist = selectedContactList
      .any((contact) => contact.emailAddress == emailAddress.emailAddress);
    log('ContactController::selectContact:isEmailAddressExist = $isEmailAddressExist');
    if (!isEmailAddressExist) {
      selectedContactList.add(emailAddress);
    }
  }

  void handleOnDeleteContactAction(EmailAddress emailAddress) {
    log('ContactController::handleOnDeleteContactAction:emailAddress = $emailAddress');
    selectedContactList.removeWhere((contact) => contact.emailAddress == emailAddress.emailAddress);
  }

  void closeContactView() {
    textInputSearchFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    popBack();
  }

  void handleOnClearFilterAction() {
    selectedContactList.clear();
    textInputSearchFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    popBack(result: selectedContactList);
  }

  void handleOnDoneAction() {
    textInputSearchFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    popBack(result: selectedContactList);
  }

  void handleOnSearchBackAction() {
    textInputSearchController.clear();
    searchQuery.value = SearchQuery.initial();
    searchedContactList.clear();
    textInputSearchFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    searchStatus.value = SearchStatus.INACTIVE;
  }

  int _fetchMinInputLengthAutocomplete() {
    if (contactArguments.value?.session == null || _accountId == null) {
      return AppConfig.defaultMinInputLengthAutocomplete;
    }
    return getMinInputLengthAutocomplete(
      session: contactArguments.value!.session,
      accountId: _accountId!);
  }
}