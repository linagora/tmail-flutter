import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/forbidden_to_send_exception.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';

/// Refuses to send while the domain awaits mail DNS validation.
///
/// The flag is set once during domain onboarding, so the loaded session is
/// trusted as is. A stale "validated" is still caught by the server, which
/// refuses the submission with `forbiddenToSend`.
class CheckSendingAllowedInteractor {
  /// Throws [ForbiddenToSendException] if the session is not validated.
  Future<void> execute(Session session, AccountId accountId) async {
    if (!session.isMailDnsConfigurationValidated(accountId)) {
      throw ForbiddenToSendException();
    }
  }
}
