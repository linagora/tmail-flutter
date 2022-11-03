
import 'package:contact/contact/model/capability_contact.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/contact_autocomplete_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/tmail_autocomplete_bindings.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class ForwardRecipientController {

  final ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;
  final TextEditingController inputEmailForwardController = TextEditingController();

  GetAutoCompleteWithDeviceContactInteractor? _getAutoCompleteWithDeviceContactInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;
  AccountId? _accountId;
  Session? _session;
  EmailAddress? _emailAddressSelected;

  ForwardRecipientController({AccountId? accountId, Session? session}) {
    _accountId = accountId;
    _session = session;
    injectAutoCompleteBindings(_session, _accountId);
  }

  EmailAddress? get emailAddressSelected => _emailAddressSelected;

  void onClose() {
    clearAll();
    _disposeWidget();
  }

  void injectAutoCompleteBindings(Session? session, AccountId? accountId) {
    try {
      ContactAutoCompleteBindings().dependencies();
      requireCapability(session!, accountId!, [tmailContactCapabilityIdentifier]);
      TMailAutoCompleteBindings().dependencies();
      _getAutoCompleteWithDeviceContactInteractor = Get.find<GetAutoCompleteWithDeviceContactInteractor>();
      _getAutoCompleteInteractor = Get.find<GetAutoCompleteInteractor>();
    } catch (e) {
      logError('ForwardRecipientController::injectAutoCompleteBindings(): exception: $e');
    }
  }

  Future<List<EmailAddress>> getAutoCompleteSuggestion(String word) async {
    log('ForwardRecipientController::getAutoCompleteSuggestion(): $word');
    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      if (_getAutoCompleteWithDeviceContactInteractor == null || _getAutoCompleteInteractor == null) {
        log('ForwardRecipientController::getAutoCompleteSuggestion(): _getAutoCompleteWithDeviceContactInteractor is NULL');
        return <EmailAddress>[];
      } else {
        return await _getAutoCompleteWithDeviceContactInteractor!
          .execute(AutoCompletePattern(word: word, accountId: _accountId))
          .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => success is GetAutoCompleteSuccess
              ? success.listEmailAddress
              : <EmailAddress>[]));
      }
    } else {
      if (_getAutoCompleteInteractor == null) {
        log('ForwardRecipientController::getAutoCompleteSuggestion(): _getAutoCompleteInteractor is NULL');
        return <EmailAddress>[];
      } else {
        return await _getAutoCompleteInteractor!
          .execute(AutoCompletePattern(word: word, accountId: _accountId))
          .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => success is GetAutoCompleteSuccess
              ? success.listEmailAddress
              : <EmailAddress>[]));
      }
    }
  }

  void selectEmailAddress(EmailAddress? emailAddress) {
    _emailAddressSelected = emailAddress;
  }

  void clearAll() {
    inputEmailForwardController.clear();
    _emailAddressSelected = null;
  }

  void _disposeWidget() {
    inputEmailForwardController.dispose();
  }
}