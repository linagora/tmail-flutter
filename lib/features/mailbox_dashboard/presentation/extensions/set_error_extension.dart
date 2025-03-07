
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension SetErrorExtension on SetError {

  String toastMessageForSendEmailFailure({
    required AppLocalizations appLocalizations,
    String? defaultMessage,
  }) {
    if (type == SetError.tooLarge) {
      return appLocalizations.sendMessageFailureWithSetErrorTypeTooLarge;
    } else if (type == SetError.overQuota) {
      return appLocalizations.sendMessageFailureWithSetErrorTypeOverQuota;
    } else {
      return defaultMessage ?? appLocalizations.sendMessageFailure;
    }
  }

  String toastMessageForSaveEmailAsDraftFailure({
    required AppLocalizations appLocalizations,
    String? defaultMessage,
  }) {
    if (type == SetError.tooLarge) {
      return appLocalizations.saveEmailAsDraftFailureWithSetErrorTypeTooLarge;
    } else if (type == SetError.overQuota) {
      return appLocalizations.saveEmailAsDraftFailureWithSetErrorTypeOverQuota;
    } else {
      return defaultMessage ?? appLocalizations.saveEmailAsDraftFailure;
    }
  }
}