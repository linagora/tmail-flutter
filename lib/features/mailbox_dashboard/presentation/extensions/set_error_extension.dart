
import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension SetErrorExtension on SetError {

  String toastMessageForSendEmailFailure(BuildContext context) {
    if (type == SetError.tooLarge) {
      return AppLocalizations.of(context).sendMessageFailureWithSetErrorTypeTooLarge;
    } else if (type == SetError.overQuota) {
      return AppLocalizations.of(context).sendMessageFailureWithSetErrorTypeOverQuota;
    } else {
      return AppLocalizations.of(context).sendMessageFailure;
    }
  }

  String toastMessageForSaveEmailAsDraftFailure(BuildContext context) {
    if (type == SetError.tooLarge) {
      return AppLocalizations.of(context).saveEmailAsDraftFailureWithSetErrorTypeTooLarge;
    } else if (type == SetError.overQuota) {
      return AppLocalizations.of(context).saveEmailAsDraftFailureWithSetErrorTypeOverQuota;
    } else {
      return AppLocalizations.of(context).saveEmailAsDraftFailure;
    }
  }
}