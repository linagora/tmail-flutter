
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
import 'package:tmail_ui_user/features/emails_forward_creator/presentation/model/mails_forward_creator_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/session_extension.dart';

class EmailsForwardCreatorController extends BaseController {

  final inputEmailForwardController = TextEditingController();
  final ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;
  final _forwardController = Get.find<ForwardController>();

  late AccountId _accountId;
  late Session? _session;
  late GetAutoCompleteWithDeviceContactInteractor _getAutoCompleteWithDeviceContactInteractor;
  late GetAutoCompleteInteractor _getAutoCompleteInteractor;

  final listEmailForwards = RxSet<EmailAddress>();

  EmailsForwardCreatorController(
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
      _session = arguments.session;
    }
  }

  Future<List<EmailAddress>> getAutoCompleteSuggestion(
      {required String word}) async {
    log('EmailsForwardCreatorController::getAutoCompleteSuggestion(): $word | $_contactSuggestionSource');

    if(_session?.hasSupportAutoComplete != true) return <EmailAddress>[];

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
    inputEmailForwardController.clear();

    if(kIsWeb) {
      _forwardController.accountDashBoardController.emailsForwardCreatorIsActive.toggle();
      _forwardController.handleAddRecipients(listEmailForwards.toList());
      _clearListEmailForwards();
    } else {
      popBack(result: listEmailForwards.toList());
    }
  }
}