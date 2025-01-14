
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
import 'package:tmail_ui_user/features/composer/domain/state/get_device_contact_suggestions_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_all_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/contact_autocomplete_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/tmail_autocomplete_bindings.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ForwardRecipientController {

  final ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;
  final TextEditingController inputRecipientController = TextEditingController();

  GetAllAutoCompleteInteractor? _getAllAutoCompleteInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;
  GetDeviceContactSuggestionsInteractor? _getDeviceContactSuggestionsInteractor;
  AccountId? _accountId;
  Session? _session;

  final listRecipients = RxList<EmailAddress>();

  ForwardRecipientController({AccountId? accountId, Session? session}) {
    _accountId = accountId;
    _session = session;
    injectAutoCompleteBindings(_session, _accountId);
  }

  void onClose() {
    clearAll();
    _disposeWidget();
  }

  void injectAutoCompleteBindings(Session? session, AccountId? accountId) {
    try {
      ContactAutoCompleteBindings().dependencies();
      requireCapability(session!, accountId!, [tmailContactCapabilityIdentifier]);
      TMailAutoCompleteBindings().dependencies();
    } catch (e) {
      logError('ForwardRecipientController::injectAutoCompleteBindings(): exception: $e');
    }
  }

  Future<List<EmailAddress>> getAutoCompleteSuggestion(String word, {int? limit}) async {
    log('ForwardRecipientController::getAutoCompleteSuggestion():word = $word | limit = $limit');
    _getAllAutoCompleteInteractor = getBinding<GetAllAutoCompleteInteractor>();
    _getAutoCompleteInteractor = getBinding<GetAutoCompleteInteractor>();
    _getDeviceContactSuggestionsInteractor = getBinding<GetDeviceContactSuggestionsInteractor>();

    final autoCompletePattern = AutoCompletePattern(
      word: word,
      limit: limit,
      accountId: _accountId,
    );
    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      if (_getAllAutoCompleteInteractor != null) {
        return await _getAllAutoCompleteInteractor!
          .execute(autoCompletePattern)
          .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => success is GetAutoCompleteSuccess
              ? success.listEmailAddress
              : <EmailAddress>[]
          ));
      } else if (_getDeviceContactSuggestionsInteractor != null) {
        return await _getDeviceContactSuggestionsInteractor!
          .execute(autoCompletePattern)
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
          .execute(autoCompletePattern)
          .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => success is GetAutoCompleteSuccess
              ? success.listEmailAddress
              : <EmailAddress>[]
          ));
      }
    }
  }

  void clearAll() {
    inputRecipientController.clear();
    listRecipients.clear();
  }

  void _disposeWidget() {
    inputRecipientController.dispose();
  }
}