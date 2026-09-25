
import 'package:tmail_ui_user/features/composer/domain/exceptions/invalid_recipients_exception.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/handle_recipients_collapsed_extensions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension InvalidRecipientsExtension on ComposerController {
  /// Keeps the composer open on an `invalidRecipients` SetError: the rejected
  /// addresses are highlighted in the recipient fields and named in a toast so
  /// the user can fix them and send again. The email Email/set already
  /// created is deleted in the background so a resend does not duplicate it.
  void handleInvalidRecipientsFailure(InvalidRecipientsException exception) {
    mailboxDashBoardController
        .deleteEmailPermanentlyInBackground(exception.createdEmailId);

    invalidRecipients.value = exception.invalidRecipients
        .map((address) => address.toLowerCase())
        .toSet();
    showFullRecipients();

    if (currentOverlayContext == null || currentContext == null) return;

    appToast.showToastErrorMessage(
      currentOverlayContext!,
      AppLocalizations.of(currentContext!).sendMessageFailureWithInvalidRecipients(
        exception.invalidRecipients.join(', '),
      ),
    );
  }
}
