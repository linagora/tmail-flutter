
import 'package:jmap_dart_client/jmap/core/error/error_type.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/set_error_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

mixin HandleMessageFailureMixin {

  ({String message, ErrorType? errorType}) getMessageFailure({
    required AppLocalizations appLocalizations,
    dynamic exception,
    bool isDraft = false,
  }) {
    final fallbackMessage = isDraft
        ? appLocalizations.warningMessageWhenSaveEmailToDraftsFailure
        : appLocalizations.warningMessageWhenSendEmailFailure;

    if (exception is! SetMethodException) {
      return (message: fallbackMessage, errorType: null);
    }

    for (final error in exception.mapErrors.values) {
      if (error.type == SetError.tooLarge || error.type == SetError.overQuota) {
        final message = isDraft
            ? error.toastMessageForSaveEmailAsDraftFailure(
                appLocalizations: appLocalizations,
                defaultMessage: fallbackMessage,
              )
            : error.toastMessageForSendEmailFailure(
                appLocalizations: appLocalizations,
                defaultMessage: fallbackMessage,
              );

        return (message: message, errorType: error.type);
      }
    }

    return (message: fallbackMessage, errorType: null);
  }
}