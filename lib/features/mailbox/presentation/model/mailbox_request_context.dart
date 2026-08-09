import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

/// The session and account a mailbox action must run against.
///
/// A mailbox belonging to another user's delegated account has to be acted upon
/// with that account's id, not the signed-in user's. Resolving this context
/// makes "which account" an explicit input to every action instead of an
/// implicit read of the primary account.
class MailboxRequestContext {
  final Session session;
  final AccountId accountId;
  final bool isPrimaryAccount;

  const MailboxRequestContext({
    required this.session,
    required this.accountId,
    required this.isPrimaryAccount,
  });
}
