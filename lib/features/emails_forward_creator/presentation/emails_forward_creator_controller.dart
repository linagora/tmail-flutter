
import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class EmailsForwardCreatorController extends BaseController {

  final inputEmailForwardController = TextEditingController();
  final ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;
  final _forwardController = Get.find<ForwardController>();

  GetAutoCompleteWithDeviceContactInteractor? _getAutoCompleteWithDeviceContactInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;

  final listEmailForwards = RxSet<EmailAddress>();

  EmailsForwardCreatorController();

  AccountId? get _accountId => _forwardController.emailsForwardCreatorArguments.value?.accountId;

  Session? get _session => _forwardController.emailsForwardCreatorArguments.value?.session;

  @override
  void onReady() {
    injectAutoCompleteBindings(_session, _accountId);
    super.onReady();
  }

  @override
  void onClose() {
    inputEmailForwardController.dispose();
    super.onClose();
  }

  @override
  void onDone() {}

  @override
  void onError(error) {}

  @override
  void injectAutoCompleteBindings(Session? session, AccountId? accountId) {
    try {
      super.injectAutoCompleteBindings(session, accountId);
      _getAutoCompleteWithDeviceContactInteractor = Get.find<GetAutoCompleteWithDeviceContactInteractor>();
      _getAutoCompleteInteractor = Get.find<GetAutoCompleteInteractor>();
    } catch (e) {
      logError('EmailsForwardCreatorController::injectAutoCompleteBindings(): $e');
    }
  }

  Future<List<EmailAddress>> getAutoCompleteSuggestion(String word) async {
    log('EmailsForwardCreatorController::getAutoCompleteSuggestion(): $word | $_contactSuggestionSource');
    try {
      _getAutoCompleteWithDeviceContactInteractor = Get.find<GetAutoCompleteWithDeviceContactInteractor>();
      _getAutoCompleteInteractor = Get.find<GetAutoCompleteInteractor>();
    } catch (e) {
      logError('EmailsForwardCreatorController::getAutoCompleteSuggestion(): Exception $e');
    }

    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      if (_getAutoCompleteWithDeviceContactInteractor == null || _getAutoCompleteInteractor == null) {
        logError('EmailsForwardCreatorController::_getAutoCompleteWithDeviceContactInteractor(): is null');
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
        logError('EmailsForwardCreatorController::_getAutoCompleteInteractor(): is null');
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

  void addToListEmailForwards(EmailAddress emailAddress) {
    if(emailAddress.email !=null && emailAddress.email!.isNotEmpty) {
      listEmailForwards.add(emailAddress);
    }
  }

  void clearAll() {
    inputEmailForwardController.clear();
  }

  void _clearListEmailForwards() {
    listEmailForwards.clear();
  }

  void closeView(BuildContext context) {
    FocusScope.of(context).unfocus();
    clearAll();

    if(kIsWeb) {
      _clearListEmailForwards();
      _forwardController.accountDashBoardController.emailsForwardCreatorIsActive.toggle();
    } else {
      popBack();
    }
  }

  void addEmailForwards(BuildContext context) {
    FocusScope.of(context).unfocus();
    if(inputEmailForwardController.text.trim().isNotEmpty) {
      listEmailForwards.add(EmailAddress(null, inputEmailForwardController.text.trim()));
    }
    clearAll();

    if (listEmailForwards.isNotEmpty) {
      final newListEmailForwards = List<EmailAddress>.from(listEmailForwards);
      _forwardController.handleAddRecipients(newListEmailForwards);
    }

    if(kIsWeb) {
      _clearListEmailForwards();
      _forwardController.accountDashBoardController.emailsForwardCreatorIsActive.toggle();
    } else {
      popBack();
    }
  }
}