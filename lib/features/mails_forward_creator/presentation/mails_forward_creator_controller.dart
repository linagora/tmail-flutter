
import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/mails_forward_creator/presentation/model/mails_forward_creator_arguments.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RulesFilterCreatorController extends BaseController {

  final inputEmailForwardController = TextEditingController();
  final ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;

  late AccountId _accountId;
  late GetAutoCompleteWithDeviceContactInteractor _getAutoCompleteWithDeviceContactInteractor;
  late GetAutoCompleteInteractor _getAutoCompleteInteractor;

  final listEmailForwards = <String>[].obs;

  RulesFilterCreatorController(
      this._getAutoCompleteWithDeviceContactInteractor,
      this._getAutoCompleteInteractor,
      );

  @override
  void onReady() {
    _getArguments();
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

  void _getArguments() {
    final arguments = Get.arguments;
    if (arguments is MailsForwardCreatorArguments) {
      _accountId = arguments.accountId;
    }
  }

  Future<List<EmailAddress>> getAutoCompleteSuggestion(
      {required String word}) async {
    log('ComposerController::getAutoCompleteSuggestion(): $word | $_contactSuggestionSource');

    _getAutoCompleteWithDeviceContactInteractor = Get.find<GetAutoCompleteWithDeviceContactInteractor>();
    _getAutoCompleteInteractor = Get.find<GetAutoCompleteInteractor>();

    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      return await _getAutoCompleteWithDeviceContactInteractor
          .execute(AutoCompletePattern(word: word, accountId: _accountId))
          .then((value) => value.fold(
              (failure) => <EmailAddress>[],
              (success) => success is GetAutoCompleteSuccess ? success.listEmailAddress : <EmailAddress>[]));
    }
    return await _getAutoCompleteInteractor
        .execute(AutoCompletePattern(word: word, accountId: _accountId))
        .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => success is GetAutoCompleteSuccess ? success.listEmailAddress : <EmailAddress>[]));
  }

  void _clearAll() {
    inputEmailForwardController.clear();
  }

  void closeView(BuildContext context) {
    FocusScope.of(context).unfocus();
    popBack();
  }
}