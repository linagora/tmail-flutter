
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:tmail_ui_user/features/emails_forward_creator/presentation/model/email_forward_creator_arguments.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnAddEmailForwardCallback = Function(List<EmailAddress> listEmailAddress);

class EmailsForwardCreatorController extends BaseController {

  final ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;

  GetAutoCompleteWithDeviceContactInteractor? _getAutoCompleteWithDeviceContactInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;

  final listEmailForwards = RxSet<EmailAddress>();

  TextEditingController? inputEmailForwardController;

  EmailForwardCreatorArguments? arguments;
  OnAddEmailForwardCallback? onAddEmailForwardCallback;
  VoidCallback? onDismissForwardCreatorCallback;
  AccountId? _accountId;
  Session? _session;

  @override
  void onInit() {
    super.onInit();
    inputEmailForwardController = TextEditingController();
  }

  @override
  void onReady() {
    super.onReady();
    if (arguments != null) {
      _accountId = arguments!.accountId;
      _session = arguments!.session;
      injectAutoCompleteBindings(_session, _accountId);
    }
  }

  @override
  void onClose() {
    _disposeWidget();
    super.onClose();
  }

  @override
  void onDone() {}

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
    try {
      _getAutoCompleteWithDeviceContactInteractor = Get.find<GetAutoCompleteWithDeviceContactInteractor>();
      _getAutoCompleteInteractor = Get.find<GetAutoCompleteInteractor>();
    } catch (e) {
      logError('EmailsForwardCreatorController::getAutoCompleteSuggestion(): Exception $e');
    }

    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      if (_getAutoCompleteWithDeviceContactInteractor == null || _getAutoCompleteInteractor == null) {
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
    if (emailAddress.email != null && emailAddress.email!.isNotEmpty) {
      listEmailForwards.add(emailAddress);
    }
  }

  void clearAll() {
    inputEmailForwardController?.clear();
  }

  void _disposeWidget() {
    inputEmailForwardController?.dispose();
    inputEmailForwardController = null;
  }

  void closeView(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (BuildUtils.isWeb) {
      _disposeWidget();
      onDismissForwardCreatorCallback?.call();
    } else {
      popBack();
    }
  }

  void addEmailForwards(BuildContext context) {
    FocusScope.of(context).unfocus();

    final emailInput = inputEmailForwardController?.text.trim();
    if (emailInput?.isNotEmpty == true && emailInput?.isEmail == true) {
      listEmailForwards.add(EmailAddress(null, emailInput));
    }

    final newListEmailForwardNeedAdded = listEmailForwards.toList();
    log('EmailsForwardCreatorController::addEmailForwards(): newListEmailForwardNeedAdded: $newListEmailForwardNeedAdded');

    if (BuildUtils.isWeb) {
      _disposeWidget();
      onAddEmailForwardCallback?.call(newListEmailForwardNeedAdded);
    } else {
      popBack(result: newListEmailForwardNeedAdded);
    }
  }
}