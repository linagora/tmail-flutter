
import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_device_contact_suggestions_state.dart';

mixin AutoCompleteResultMixin {

  FutureOr<List<EmailAddress>> handleAutoCompleteResultState({
    required Either<Failure, Success> resultState,
    required String queryString,
  }) {
    return resultState.fold(
      (failure) => <EmailAddress>[],
      (success) => handleAutoCompleteSuccess(success, queryString)
    );
  }

  List<EmailAddress> handleAutoCompleteSuccess(Success success, String queryString) {
    List<EmailAddress> listEmailAddress = [];

    if (success is GetAutoCompleteSuccess) {
      listEmailAddress = success.listEmailAddress;
    } else if (success is GetDeviceContactSuggestionsSuccess) {
      listEmailAddress = success.listEmailAddress;
    }

    if (listEmailAddress.isEmpty && GetUtils.isEmail(queryString)) {
      return [EmailAddress(queryString, queryString)];
    }

    bool isEmailExist = listEmailAddress
      .any((email) => email.emailAddress == queryString);
    if (GetUtils.isEmail(queryString) && !isEmailExist) {
      listEmailAddress.insert(0, EmailAddress(queryString, queryString));
    }

    return listEmailAddress;
  }
}