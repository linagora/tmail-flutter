import 'package:email_recovery/email_recovery/capability_deleted_messages_vault.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class MailboxUtils {
  static bool isDeletedMessageVaultSupported(Session? session, AccountId? accountId) {
    if (session == null || accountId == null) {
      return false;
    }
    return capabilityDeletedMessagesVault.isSupported(session, accountId);
  }
}