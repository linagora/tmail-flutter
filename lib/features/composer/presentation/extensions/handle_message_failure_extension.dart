
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/set_error_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension HandleMessageFailureExtension on ComposerController {

  String getMessageFailure({
    required AppLocalizations appLocalizations,
    dynamic exception,
    bool isDraft = false,
  }) {
    if (exception is! SetMethodException) {
      return isDraft
        ? appLocalizations.warningMessageWhenSaveEmailToDraftsFailure
        : appLocalizations.warningMessageWhenSendEmailFailure;
    }

    for (var error in exception.mapErrors.values) {
      if (error.type != SetError.tooLarge && error.type != SetError.overQuota) {
        continue;
      }

      if (isDraft) {
        return error.toastMessageForSaveEmailAsDraftFailure(
          appLocalizations: appLocalizations,
          defaultMessage:appLocalizations.warningMessageWhenSaveEmailToDraftsFailure,
        );
      } else {
        return error.toastMessageForSendEmailFailure(
          appLocalizations: appLocalizations,
          defaultMessage:appLocalizations.warningMessageWhenSendEmailFailure,
        );
      }
    }

    return isDraft
      ? appLocalizations.warningMessageWhenSaveEmailToDraftsFailure
      : appLocalizations.warningMessageWhenSendEmailFailure;
  }
}