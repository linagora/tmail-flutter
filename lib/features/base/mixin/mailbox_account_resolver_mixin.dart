import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_request_context.dart';

/// Resolves the account a mailbox action must target from the mailbox itself.
///
/// Turns "which account" from an implicit read of the primary account into an
/// explicit value derived from the target mailbox, so an action on a delegated
/// account's mailbox is dispatched with that account's id.
mixin MailboxAccountResolverMixin {
  AccountId? get primaryAccountId;
  Session? get session;

  /// The account that owns [mailbox]. Falls back to the primary account for
  /// mailboxes that carry no account (the app-local virtual folders).
  AccountId? accountIdOf(PresentationMailbox mailbox) =>
      mailbox.accountId ?? primaryAccountId;

  /// Whether [mailbox] belongs to another user's delegated account.
  bool isOtherUserMailbox(PresentationMailbox mailbox) =>
      mailbox.accountId != null && mailbox.accountId != primaryAccountId;

  /// The session and owning account for an action on [mailbox], or null when
  /// there is no session or the account cannot be resolved.
  MailboxRequestContext? requestContextOf(PresentationMailbox mailbox) {
    final currentSession = session;
    final accountId = accountIdOf(mailbox);
    if (currentSession == null || accountId == null) return null;

    return MailboxRequestContext(
      session: currentSession,
      accountId: accountId,
      isPrimaryAccount: accountId == primaryAccountId,
    );
  }
}
