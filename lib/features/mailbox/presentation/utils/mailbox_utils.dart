import 'package:email_recovery/email_recovery/capability_deleted_messages_vault.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class MailboxUtils {
  /// A synthesized namespace matching what James emits for a delegated mailbox,
  /// so a Cyrus other-user account renders through the same team-mailbox path
  /// with the owner shown as a subtitle. Cyrus has no namespace of its own; the
  /// owning account is still carried on the mailbox's accountId for write
  /// routing. The `[owner]` form is what PresentationMailbox.emailTeamMailBoxes
  /// parses.
  static Namespace delegatedNamespace(String ownerName) =>
      Namespace('Delegated[$ownerName]');

  static bool isDeletedMessageVaultSupported(Session? session, AccountId? accountId) {
    if (session == null || accountId == null) {
      return false;
    }
    return capabilityDeletedMessagesVault.isSupported(session, accountId);
  }

  /// The delegated accounts (other users) in [session], excluding [primary].
  ///
  /// A session's accounts also include contacts, calendar or file-storage
  /// accounts; Mailbox/get on those returns accountNotSupportedByMethod, so the
  /// JMAP Mail capability filter is mandatory. isPersonal is deliberately not
  /// used: some deployments mark delegated accounts isPersonal.
  static List<AccountId> resolveOtherUserAccountIds(
    Session session,
    AccountId primary,
  ) {
    return session.accounts.entries
        .where((entry) => entry.key != primary)
        .where((entry) =>
            CapabilityIdentifier.jmapMail.isSupported(session, entry.key))
        .map((entry) => entry.key)
        .toList();
  }
}