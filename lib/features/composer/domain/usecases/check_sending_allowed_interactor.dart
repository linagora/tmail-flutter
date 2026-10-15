import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/forbidden_to_send_exception.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/home/domain/repository/session_repository.dart';

/// Refuses to send while the domain awaits mail DNS validation.
///
/// The session is loaded once, so only a cached "not validated" is checked
/// against a fresh session. If that fetch fails, the send goes ahead: the
/// server still refuses it with `forbiddenToSend`.
class CheckSendingAllowedInteractor {
  final SessionRepository _sessionRepository;

  CheckSendingAllowedInteractor(this._sessionRepository);

  /// Throws [ForbiddenToSendException] if the fresh session is not validated.
  Future<void> execute(Session session, AccountId accountId) async {
    if (session.isMailDnsConfigurationValidated(accountId)) return;

    final Session latestSession;
    try {
      latestSession = await _sessionRepository.getSession();
    } catch (e) {
      logWarning('CheckSendingAllowedInteractor::execute: Exception: $e');
      return;
    }

    if (!latestSession.isMailDnsConfigurationValidated(accountId)) {
      throw ForbiddenToSendException();
    }
  }
}
