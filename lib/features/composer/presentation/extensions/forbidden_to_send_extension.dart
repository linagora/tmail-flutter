import 'package:tmail_ui_user/features/composer/domain/exceptions/forbidden_to_send_exception.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/domain_activation_pending_dialog.dart';

extension ForbiddenToSendExtension on ComposerController {
  /// Keeps the composer open so the email can be saved as a draft, and
  /// deletes the copy the refused send left in Outbox.
  Future<void> handleForbiddenToSendFailure(ForbiddenToSendException exception) {
    mailboxDashBoardController
        .deleteEmailPermanentlyInBackground(exception.createdEmailId);
    return showDomainActivationPendingDialog();
  }
}
