
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/handle_recipients_collapsed_extensions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension InvalidRecipientsExtension on ComposerController {
  /// Clears the server-side invalid mark of the addresses the user removed or
  /// edited, keeping it on the ones still present.
  void dropInvalidRecipientsNoLongerListed() {
    if (invalidRecipients.value.isEmpty) return;

    final remainingAddresses =
        allListEmailAddressWithoutReplyTo.toNormalizedEmailSet();
    final remainingInvalidRecipients =
        invalidRecipients.value.intersection(remainingAddresses);

    if (remainingInvalidRecipients.length != invalidRecipients.value.length) {
      invalidRecipients.value = remainingInvalidRecipients;
    }
  }

  /// Keeps the composer open on an `invalidRecipients` SetError: the rejected
  /// addresses are highlighted in the recipient fields and named in a toast so
  /// the user can fix them and send again.
  void handleInvalidRecipientsFailure(Set<String> rejectedAddresses) {
    invalidRecipients.value = rejectedAddresses
        .map((address) => address.toLowerCase())
        .toSet();
    showFullRecipients();

    if (currentOverlayContext == null || currentContext == null) return;

    appToast.showToastErrorMessage(
      currentOverlayContext!,
      AppLocalizations.of(currentContext!)
          .sendMessageFailureWithInvalidRecipients(rejectedAddresses.join(', ')),
    );
  }
}
